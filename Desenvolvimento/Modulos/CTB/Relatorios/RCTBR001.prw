#Include "totvs.ch"
#Include "TopConn.ch"

#define F_BLOCK  512

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCTBRA01  บAutor  ณLucas Fl๓ridi Leme  บ Data ณ  05/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Razใo contแbil em excel                                    บฑฑ
ฑฑบ 27/01/25 ณ Mแrio Cavenaghi - #2334 - Erro relat๓rio @razใo            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RCTBR001()
	Local cPerg		:= PadR("RCTBR001",10)

	AjustaSx1(cPerg)
	If Pergunte(cPerg,.T.)

		Processa( {|| MexProcessa() },"Aguarde" ,"Processando...")
		//	Processa( {|| GeraExcel("TMP") },"Aguarde" ,"Gerando arquivo excel...")

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMexProcessบAutor  ณMicrosiga           บ Data ณ  08/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MexProcessa()
	Local _x
	Local cTexto := ""
	Local _aStruct := {}

	cQry := "SELECT CT2_FILIAL,CT2_TPSALD TIPOSALDO, CT2_MOEDLC MOEDA  " +Chr(13)
	cQry += ",CONVERT(CHAR(10),CONVERT(DATE,CT2_DATA),103) 'DATA'  " +Chr(13)
	cQry += ",CT1_CONTA CONTA " +Chr(13)
	cQry += ",CT1_DESC01 DESCRICAO " +Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_DEBITO THEN CT2_CCD WHEN CT2_CREDIT THEN CT2_CCC ELSE '' END CC_PARTIDA "+Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_DEBITO THEN CT2_CLVLDB WHEN CT2_CREDIT THEN CT2_CLVLCR ELSE '' END CLVL_PARTIDA "+Chr(13)
	cQry += ",LTRIM(RTRIM(CT2_HIST))+ISNULL((SELECT RTRIM(LTRIM(CT2_HIST))  " +Chr(13)
	cQry += "					FROM "+RetSqlName("CT2")+" CT22  " +Chr(13)
	cQry += "					WHERE CT22.D_E_L_E_T_<>'*' AND CT2.CT2_FILIAL=CT22.CT2_FILIAL AND CT22.CT2_SEQUEN=CT2.CT2_SEQUEN AND CT22.CT2_SEQLAN=CT2.CT2_SEQLAN " +Chr(13)
	cQry += "					AND CT22.CT2_DATA=CT2.CT2_DATA AND CT22.CT2_LOTE=CT2.CT2_LOTE AND CT22.CT2_SBLOTE=CT2.CT2_SBLOTE AND CT22.CT2_DOC=CT2.CT2_DOC " +Chr(13)

	//--Incluido para melhoria de Performance #ES 20181107
	cQry += "					AND CT2_TPSALD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +Chr(13)
	IF !Empty(mv_par09)
		cQry += "				AND CT2_MOEDLC = '"+MV_PAR09+"' "+Chr(13)
	EndIF
	cQry += "					AND CT2_DATA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' " +Chr(13)
	cQry += "					AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +Chr(13)
	//-- #ES 20181107
	cQry += "					AND CT22.CT2_TPSALD=CT2.CT2_TPSALD AND CT2_SEQHIS='002' AND CT2_DC='4'),'') " +Chr(13)
	cQry += "				+ISNULL((SELECT RTRIM(LTRIM(CT2_HIST))  " +Chr(13)
	cQry += "					FROM "+RetSqlName("CT2")+" CT22  " +Chr(13)
	cQry += "					WHERE CT22.D_E_L_E_T_<>'*' AND CT2.CT2_FILIAL=CT22.CT2_FILIAL AND CT22.CT2_SEQUEN=CT2.CT2_SEQUEN AND CT22.CT2_SEQLAN=CT2.CT2_SEQLAN " +Chr(13)
	cQry += "					AND CT22.CT2_DATA=CT2.CT2_DATA AND CT22.CT2_LOTE=CT2.CT2_LOTE AND CT22.CT2_SBLOTE=CT2.CT2_SBLOTE AND CT22.CT2_DOC=CT2.CT2_DOC " +Chr(13)
	//--Incluido para melhoria de Performance #ES 20181107
	cQry += "					AND CT2_TPSALD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +Chr(13)
	IF !Empty(mv_par09)
		cQry += "				AND CT2_MOEDLC = '"+MV_PAR09+"' "+Chr(13)
	EndIF
	cQry += "					AND CT2_DATA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' " +Chr(13)
	cQry += "					AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +Chr(13)
	//-- #ES 20181107
	cQry += "					AND CT22.CT2_TPSALD=CT2.CT2_TPSALD AND CT2_SEQHIS='003' AND CT2_DC='4'),'') " +Chr(13)
	cQry += "				+ISNULL((SELECT RTRIM(LTRIM(CT2_HIST))  " +Chr(13)
	cQry += "					FROM "+RetSqlName("CT2")+" CT22  " +Chr(13)
	cQry += "					WHERE CT22.D_E_L_E_T_<>'*' AND CT2.CT2_FILIAL=CT22.CT2_FILIAL AND CT22.CT2_SEQUEN=CT2.CT2_SEQUEN AND CT22.CT2_SEQLAN=CT2.CT2_SEQLAN " +Chr(13)
	cQry += "					AND CT22.CT2_DATA=CT2.CT2_DATA AND CT22.CT2_LOTE=CT2.CT2_LOTE AND CT22.CT2_SBLOTE=CT2.CT2_SBLOTE AND CT22.CT2_DOC=CT2.CT2_DOC " +Chr(13)
	//--Incluido para melhoria de Performance #ES 20181107
	cQry += "					AND CT2_TPSALD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +Chr(13)
	IF !Empty(mv_par09)
		cQry += "				AND CT2_MOEDLC = '"+MV_PAR09+"' "+Chr(13)
	EndIF
	cQry += "					AND CT2_DATA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' " +Chr(13)
	cQry += "					AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +Chr(13)
	//-- #ES 20181107
	cQry += "					AND CT22.CT2_TPSALD=CT2.CT2_TPSALD AND CT2_SEQHIS='004' AND CT2_DC='4'),'') " +Chr(13)
	cQry += "				+ISNULL((SELECT RTRIM(LTRIM(CT2_HIST))  " +Chr(13)
	cQry += "					FROM "+RetSqlName("CT2")+" CT22  " +Chr(13)
	cQry += "					WHERE CT22.D_E_L_E_T_<>'*' AND CT2.CT2_FILIAL=CT22.CT2_FILIAL AND CT22.CT2_SEQUEN=CT2.CT2_SEQUEN AND CT22.CT2_SEQLAN=CT2.CT2_SEQLAN " +Chr(13)
	cQry += "					AND CT22.CT2_DATA=CT2.CT2_DATA AND CT22.CT2_LOTE=CT2.CT2_LOTE AND CT22.CT2_SBLOTE=CT2.CT2_SBLOTE AND CT22.CT2_DOC=CT2.CT2_DOC " +Chr(13)
	cQry += "					AND CT22.CT2_TPSALD=CT2.CT2_TPSALD AND CT2_SEQHIS='005' AND CT2_DC='4'),'') " +Chr(13)
	cQry += "				+ISNULL((SELECT RTRIM(LTRIM(CT2_HIST))  " +Chr(13)
	cQry += "					FROM "+RetSqlName("CT2")+" CT22  " +Chr(13)
	cQry += "					WHERE CT22.D_E_L_E_T_<>'*' AND CT2.CT2_FILIAL=CT22.CT2_FILIAL AND CT22.CT2_SEQUEN=CT2.CT2_SEQUEN AND CT22.CT2_SEQLAN=CT2.CT2_SEQLAN " +Chr(13)
	cQry += "					AND CT22.CT2_DATA=CT2.CT2_DATA AND CT22.CT2_LOTE=CT2.CT2_LOTE AND CT22.CT2_SBLOTE=CT2.CT2_SBLOTE AND CT22.CT2_DOC=CT2.CT2_DOC " +Chr(13)
	//--Incluido para melhoria de Performance #ES 20181107
	cQry += "					AND CT2_TPSALD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +Chr(13)
	IF !Empty(mv_par09)
		cQry += "				AND CT2_MOEDLC = '"+MV_PAR09+"' "+Chr(13)
	EndIF
	cQry += "					AND CT2_DATA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' " +Chr(13)
	cQry += "					AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +Chr(13)
	//-- #ES 20181107
	cQry += "					AND CT22.CT2_TPSALD=CT2.CT2_TPSALD AND CT2_SEQHIS='006' AND CT2_DC='4'),'') HISTORICO " +Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_DEBITO THEN CT2_CREDIT WHEN CT2_CREDIT THEN CT2_DEBITO ELSE '' END XPARTIDA " +Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_DEBITO THEN CT2_VALOR ELSE 0 END DEBITO " +Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_CREDIT THEN CT2_VALOR ELSE 0 END CREDITO " +Chr(13)
	cQry += ",CASE CT1_CONTA WHEN CT2_DEBITO THEN CT2_VALOR ELSE 0 END -CASE CT1_CONTA WHEN CT2_CREDIT THEN CT2_VALOR ELSE 0 END MOVIMENTO " +Chr(13)
	cQry += ",CT2_CCD CCD " +Chr(13)
	cQry += ",CT2_CCC CCC " +Chr(13)
	cQry += ",CT2_ITEMD ITEM_D " +Chr(13)
	cQry += ",CT2_ITEMC ITEM_C " +Chr(13)
	cQry += ",CT2_CLVLDB CLVLDB " +Chr(13)
	cQry += ",CT2_CLVLCR CLVLCR " +Chr(13)
	cQry += ",CT2_AT01DB AT01DB_REG " +Chr(13)
	cQry += ",CT2_AT01CR AT01CR_REG " +Chr(13)
	cQry += ",CT2_AT02DB AT02DB_OP " +Chr(13)
	cQry += ",CT2_AT02CR AT02CR_OP " +Chr(13)
	cQry += ",CT2_AT03DB AT03DB_LOCAL " +Chr(13)
	cQry += ",CT2_AT03CR AT03CR_LOCAL " +Chr(13)
	cQry += ",CT2_AT04DB AT04DB_PROD " +Chr(13)
	cQry += ",CT2_AT04CR AT04CR_PROD " +Chr(13)
	//cQry += ",CT2_ATIVCR ATIVCR " +Chr(13)
	//cQry += ",CT2_ATIVDE ATIVDE " +Chr(13)
	cQry += ",CT2_LOTE LOTE " +Chr(13)
	cQry += ",CT2_SBLOTE SUBLOTE " +Chr(13)
	cQry += ",CT2_DOC DOCCOBTA " +Chr(13)
	cQry += ",CT2_LINHA LINHA " +Chr(13)
	cQry += ",CV3_RECORI REGORIG"+Chr(13)
	//cQry += ",CONVERT(CHAR(10),CONVERT(DATE,CT2_DATA),103)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA AS KEYBUSCA  " +Chr(13)
	//cQry += ",CV3_TABORI,CV3_RECORI "+Chr(13)
	//cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_CLIFOR WHEN 'SF1' THEN F1_FORNECE WHEN 'SD1' THEN D1_FORNECE WHEN 'SF2' THEN F2_CLIENTE WHEN 'SD2' THEN D2_CLIENTE WHEN 'SE1' THEN E1_CLIENTE WHEN 'SE2' THEN E2_FORNECE ELSE '' END CLIFOR " +Chr(13)
	cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_CLIFOR WHEN 'SF1' THEN F1_FORNECE WHEN 'SD1' THEN D1_FORNECE WHEN 'SF2' THEN F2_CLIENTE WHEN 'SD2' THEN D2_CLIENTE WHEN 'SE1' THEN E1_CLIENTE WHEN 'SE2_A' THEN SE2_A.E2_FORNECE ELSE '' END CLIFOR " +Chr(13)
	//cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_NUMERO WHEN 'SF1' THEN F1_DOC WHEN 'SD1' THEN D1_DOC WHEN 'SF2' THEN F2_DOC WHEN 'SD2' THEN D2_DOC WHEN 'SE1' THEN E1_NUM WHEN 'SE2' THEN E2_NUM ELSE '' END DOCUMENTO " +Chr(13)
	cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_NUMERO WHEN 'SF1' THEN F1_DOC WHEN 'SD1' THEN D1_DOC WHEN 'SF2' THEN F2_DOC WHEN 'SD2' THEN D2_DOC WHEN 'SE1' THEN E1_NUM WHEN 'SE2_A' THEN SE2_A.E2_NUM ELSE '' END DOCUMENTO " +Chr(13)
	//Geraldino , valida็ใo de empresa
	//If FWCodEmp() = '01'
	//	cQry += ",CASE CV3_TABORI WHEN 'SD1' THEN D1_XPO 	         WHEN 'SE5' THEN SE2_Z.E2_XPO       WHEN 'SE2' THEN SE2_A.E2_XPO         END PO       " +Chr(13) //geraldino
	//	cQry += ",CASE CV3_TABORI WHEN 'SD1' THEN P03_SD1.P03_TRADIN WHEN 'SE5' THEN P03_SE2.P03_TRADIN WHEN 'SE2' THEN P03_SE2_1.P03_TRADIN END TRADDING " +Chr(13)//geraldino
	//endif
	//-----------------------------------------
	//cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_PARCELA WHEN 'SF1' THEN '' WHEN 'SF2' THEN '' WHEN 'SE1' THEN E1_PARCELA WHEN 'SE2' THEN E2_PARCELA ELSE '' END DOC_PARC " +Chr(13)
	//cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_TIPO WHEN 'SF1' THEN F1_ESPECIE WHEN 'SF2' THEN F2_ESPECIE WHEN 'SE1' THEN E1_TIPO WHEN 'SE2' THEN E2_TIPO ELSE '' END TIPODOC " +Chr(13)
	//cQry += ",CASE CV3_TABORI WHEN 'SE5' THEN E5_DOCUMEN ELSE '' END DOC_COMP " +Chr(13)
	//cQry += ",CASE CT2_MANUAL WHEN '1' THEN 'MANUAL' ELSE 'AUTO' END 'MANUAL' " +Chr(13)
	//cQry += ",CT2_EMPORI EMPORI " +Chr(13)
	cQry += ",CT2_FILORI FILORI " +Chr(13)
	cQry += ",CT2_ORIGEM ORIGEM " +Chr(13)
	//cQry += ",CT2_ROTINA ROTINA,CT2_LP LP " +Chr(13)
	cQry += ",CT2.R_E_C_N_O_ REG_CT2 " +Chr(13)
	cQry += ",CT2_KEY,CT2_CODCLI,CT2_CODFOR" +Chr(13)
	cQry += ",CV3_TABORI,CASE CV3_TABORI WHEN 'SD1' THEN D1_COD WHEN 'SD2' THEN D2_COD WHEN 'SD3' THEN SUBSTRING(CT2_KEY,3,15) ELSE CV3_TABORI END CODPROD " +Chr(13)

	cQry += ",  CASE " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'MATA330' THEN 'MATA330 - ESTOQUE'    " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'GPEM110' THEN 'GPEM110 - FOLHA'      " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA in ('FINA370','FINA050') THEN CONCAT(CT2_ROTINA,' - FINANCEIRO') " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'CTBANFS' THEN 'CTBANFS - FATURAMENTO'" +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'CTBANFE' THEN 'CTBANFE - COMPRAS'    " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'CTBA280' THEN 'CTBA280 - RATEIO'     " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_ROTINA = 'ATFA050' THEN 'ATFA050 - ATIVO'      " +Chr(13)//Geraldino 27/02/2024
	cQry += "ELSE CT2_ROTINA END AS 'ROTINA' " +Chr(13)//Geraldino 27/02/2024
	cQry += ",  CASE " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '1' THEN 'D'  	 " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '2' THEN 'C'  	 " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '3' THEN 'PD' 	 " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '4' THEN 'C_HIST' " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '5' THEN 'RAT' 	 " +Chr(13)//Geraldino 27/02/2024
	cQry += "WHEN CT2_DC = '6' THEN 'LPAD' 	 " +Chr(13)//Geraldino 27/02/2024
	cQry += "ELSE CT2_DC END AS 'TP_LACTO' 	 " +Chr(13)//Geraldino 27/02/2024

	cQry += "FROM "+RetSqlName("CT1")+" CT1 " +Chr(13)
	cQry += "	INNER JOIN "+RetSqlName("CT2")+" CT2 ON CT2.D_E_L_E_T_<>'*' " +Chr(13)
	cQry += "		AND CT2_DC IN ('1','2','3') " +Chr(13)
	cQry += "		AND CT2_TPSALD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +Chr(13)

	IF !Empty(mv_par09)
		cQry += "		AND CT2_MOEDLC = '"+MV_PAR09+"' "+Chr(13) // INSERIDO POR CLEBER NEVES EM 26/05/2015. SOLICITADO POR มTILA GUIMARรES.
	EndIF

	cQry += "		AND CT2_DATA BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' " +Chr(13)
	cQry += "		AND CT2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +Chr(13)
	//cQry += "		AND CT2_FILORI BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +Chr(13)
	cQry += "		AND (CT2_DEBITO=CT1_CONTA OR CT2_CREDIT =CT1_CONTA) " +Chr(13)
	// cQry += "		AND CT2_FILIAL="+IF(EMPTY(xFilial("CT1")),"CT2_FILIAL","CT1_FILIAL")+" "
	cQry += "	LEFT OUTER JOIN "+RetSqlName("CV3")+" CV3 ON CV3.D_E_L_E_T_<>'*' AND CV3_FILIAL=CT2_FILIAL AND CV3_RECDES=CONVERT(VARCHAR,CT2.R_E_C_N_O_) " +Chr(13)
	cQry += "		AND CV3.R_E_C_N_O_=(SELECT MAX(R_E_C_N_O_) FROM "+RetSqlName("CV3")+" CV3X WHERE CV3_RECDES=CONVERT(VARCHAR,CT2.R_E_C_N_O_)  AND CV3_FILIAL = CT2.CT2_FILIAL ) " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D_E_L_E_T_<>'*' AND SD1.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_<>'*' AND SD2.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.D_E_L_E_T_<>'*' AND SF1.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_<>'*' AND SF2.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SE1")+" SE1 ON SE1.D_E_L_E_T_<>'*' AND SE1.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SE2")+" SE2_A ON SE2_A.D_E_L_E_T_<>'*' AND SE2_A.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	cQry += "	LEFT OUTER JOIN "+RetSqlName("SE5")+" SE5 ON SE5.D_E_L_E_T_<>'*' AND SE5.R_E_C_N_O_=CV3_RECORI " +Chr(13)
	//If FWCodEmp() = '01'//geraldino, valida็ใo da empresa
	//	cQry += "	LEFT OUTER JOIN "+RetSqlName("P03")+" P03_SD1 ON P03_SD1.D_E_L_E_T_<>'*' AND D1_XPO = P03_SD1.P03_ID " +Chr(13)//geraldino 19/12/2024
	//	cQry += "	LEFT OUTER JOIN "+RetSqlName("SE2")+" SE2_Z ON SE2_Z.D_E_L_E_T_<>'*' AND E5_NUMERO = SE2_Z.E2_NUM AND E5_FORNECE = SE2_Z.E2_FORNECE AND E5_LOJA = SE2_Z.E2_LOJA AND E5_PREFIXO = SE2_Z.E2_PREFIXO AND E5_PARCELA = SE2_Z.E2_PARCELA AND E5_TIPO = SE2_Z.E2_TIPO " +Chr(13)//geraldino 19/12/2024
	//	cQry += "	LEFT OUTER JOIN "+RetSqlName("P03")+" P03_SE2 ON P03_SE2.D_E_L_E_T_<>'*' AND SE2_Z.E2_XPO = P03_SE2.P03_ID " +Chr(13)//geraldino 19/12/2024
	//	cQry += "	LEFT OUTER JOIN "+RetSqlName("P03")+" P03_SE2_1 ON P03_SE2_1.D_E_L_E_T_<>'*' AND SE2_A.E2_XPO = P03_SE2_1.P03_ID " +Chr(13)//geraldino 19/12/2024
	//endif
	//------------------------------------------------------
	cQry += "WHERE CT1_CONTA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +Chr(13)
	cQry += "AND CT1.D_E_L_E_T_<>'*' "
	cQry += "ORDER BY CT2_TPSALD,CT2_DATA,CT1_CONTA " +Chr(13)

	Memowrite("RCTBR001.txt",cQry)
	TcQuery cQry New Alias "QRY1"

	TcSetField("QRY1","DEBITO","N",TamSx3("CT2_VALOR")[1],2)
	TcSetField("QRY1","CREDITO","N",TamSx3("CT2_VALOR")[1],2)
	TcSetField("QRY1","REG_CT2","N",14,0)

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
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
		AADD(_aLinha,' <Worksheet ss:Name="RAZAO">')
		AADD(_aLinha,'  <Table ss:ExpandedColumnCount="100" ss:ExpandedRowCount="1048576" x:FullColumns="1"')
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
		_aStruct := QRY1->(DbStruct())
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
				If _cCpo $ "EMISSAO"
					AADD(_aLinha,'    <Cell ss:StyleID="sDate"><Data ss:Type="DateTime">'+QRY1->&(_cCpo)+'</Data></Cell>')
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
		Alert("Nใo hแ dados!!!")
	EndIf
	QRY1->(DbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณ                    บ Data ณ  02/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
	Local aRea	:= GetArea()
	Local aSx1	:= {}
	Local i := 0

	DBSelectArea("SX1")
	SX1->(DBSetOrder(1))
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
	SX1->(DBSeek(cPerg+"01"))
	AADD(	aSx1,{ cPerg,"01","De Filial?"		,"mv_par01"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par01","","","","","SM0_01","" } )
	AADD(	aSx1,{ cPerg,"02","Ate Filial?"		,"mv_par02"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par02","","","","","SM0_01","" } )

	AADD(	aSx1,{ cPerg,"03","De Data?"		,"mv_par03"	,"D",8,0,0,"G","", 	"mv_par03","","","","","","" } )
	AADD(	aSx1,{ cPerg,"04","Ate Data?"		,"mv_par04"	,"D",8,0,0,"G","",	"mv_par04","","","","","","" } )

	AADD(	aSx1,{ cPerg,"05","De Conta?"	    ,"mv_par05"	,"C",20,0,0,"G","",	"mv_par05","","","","","CT1" } )
	AADD(	aSx1,{ cPerg,"06","Ate Conta?"		,"mv_par06"	,"C",20,0,0,"G","",	"mv_par06","","","","","CT1" } )

	AADD(	aSx1,{ cPerg,"07","De Tipo Saldo?" 	,"mv_par07"	,"C",01,0,0,"G","",	"mv_par07","","","","","SLW" } )
	AADD(	aSx1,{ cPerg,"08","Ate Tipo Saldo?" ,"mv_par08"	,"C",01,0,0,"G","",	"mv_par08","","","","","SLW" } )

	//AADD(	aSx1,{ cPerg,"09","De Fil Origem?"	,"mv_par09"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par09","","","","","SM0_01","" } ) // RETIRADO POR CLEBER NEVES EM 26/05/2015. SOLICITADO POR มTILA GUIMARรES.
	//AADD(	aSx1,{ cPerg,"10","Ate Fil Origem?"	,"mv_par10"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par10","","","","","SM0_01","" } ) // RETIRADO POR CLEBER NEVES EM 26/05/2015. SOLICITADO POR มTILA GUIMARรES.

	AADD(	aSx1,{ cPerg,"09","Qual Moeda?"		,"mv_par09"	,"C",02,0,0,"G","",	"mv_par09","","","","","CTO" } ) // INSERIDO POR CLEBER NEVES EM 26/05/2015.

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
				SX1->X1_PRESEL  := aSx1[i][8] //Pre sele็ใo do combo
				SX1->X1_GSC     := aSx1[i][9] //Tipo de componente
				SX1->X1_VAR01   := aSx1[i][10]//Variavel que carrega resposta
				SX1->X1_DEF01   := aSx1[i][11]//Defini็๕es do combo-box
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGeraExcel บAutor  ณ                    บ Data ณ  05/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao de arquivo excel 						              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCTBR003  บAutor  ณMicrosiga           บ Data ณ  07/31/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static FUNCTION NoAcento(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
	Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
	Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
	Local cCrase := "เ่์๒๙"+"ภศฬาู"
	Local cTio   := "ใ๕รี"
	Local cCecid := "็ว"
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
