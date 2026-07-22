#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#Define _crlf Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR235  บAutor  ณLucas Fl๓ridi Leme  บ Data ณ  02/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rela็ใo de notas de venda e o valo de frete referente      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 Fortaleza                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RCOMRD02()
	//Cria o MsApp
	MsApp():New('SIGACOM')
	oApp:CreateEnv()
	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")
	//Define o programa de inicializa็ใo
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
		{|| RpcSetEnv("01","0201"), }),;
		U_RCOMR002(),;
		Final("TERMINO NORMAL")}
	//Seta Atributos
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGACOM'

	//Inicia a Janela
	oApp:Activate()
Return Nil

User Function RCOMR002
	cPerg := "RCOMRD02"
	// __cInternet := NIL
	// RPCSetType(3)
	// Prepare Environment Empresa "01" Filial '0201' Tables "SA1","SF2" Modulo "EST"
	If !U_CheckAgent()
		REturn
	EndIf

	ValidPerg()
	If Pergunte(cPerg,.T.)
		Processa({||Gera(),"Processando..."})
	EndIf

Return

Static Function Gera()
	Local _x
	// createView()

	cQry := "SELECT D1_FILIAL FILIAL,D1_DOC DOC,D1_SERIE SERIE,D1_FORNECE CLIFOR,D1_LOJA LOJA "
	cQry += ",CASE WHEN D1_TIPO IN ('N','C','I','P') THEN A2_NOME ELSE A1_NOME END NOME "
	cQry += ",A1_CGC CNPJ,F1_EST ESTADO,D1_TIPO TIPO,D1_ITEM ITEM,D1_COD ID_PRODUTO,B1_DESC PRODUTO "
	cQry += ",B1_UM UM,B1_TIPO TP_PROD,D1_LOCAL DEPOSITO,D1_QUANT QUANTIDADE,D1_VUNIT VUNIT,D1_TOTAL VAL_MERC "
	cQry += ",D1_TES TES,F4_DUPLIC DUPLICATA,F4_ESTOQUE ESTOQUE,D1_CF CFOP,F4_PODER3 PODER3 "
	cQry += ",D1_PEDIDO PEDIDO,D1_ITEMPC ITEMPC,D1_OP OP,D1_EMISSAO EMISSAO,D1_DTDIGIT DTDIGIT "
	cQry += ",B1_CONTA CONTA,CT1_DESC01 DESC_CONTA,D1_CC CC,D1_CLVL CLASSE_VALOR "
	cQry += ",F1_ESPECIE ESPECIE_NF,F1_CHVNFE CHAVE,D1_NFORI NF_ORIG,D1_SERIORI SERIE_ORIG "
	cQry += ",D1_VALIPI VALIPI,D1_IPI IPI,D1_VALIMP5 VALCOF,D1_VALIMP6 VALPIS "
	cQry += ",D1_VALPIS PIS_RET,D1_VALCOF COF_RET,D1_VALCSL CSL_RET "
	cQry += ",TIT.VENC_01,TIT.VENC_02,TIT.VENC_03,TIT.VENC_04,TIT.VENC_05,TIT.VENC_06 "
	cQry += ",TIT.VENC_07,TIT.VENC_08,TIT.VENC_09,TIT.VENC_10,TIT.VENC_11,TIT.VENC_12 "
	cQry += "FROM SD1010 SD1 "
	cQry += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_='' "
	cQry += " AND F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE "
	cQry += " AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA "
	cQry += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=D1_COD "
	cQry += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON SF4.D_E_L_E_T_='' AND F4_CODIGO=D1_TES "
	cQry += "LEFT  JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_='' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA "
	cQry += "LEFT  JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_='' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA "
	cQry += "LEFT  JOIN " + RetSqlName("CT1") + " CT1 ON CT1.D_E_L_E_T_='' "
	cQry += " AND CT1_FILIAL=SUBSTRING(D1_FILIAL,1,2) AND CT1_CONTA=B1_CONTA "
	cQry += "LEFT JOIN ( "
	cQry += " SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_NUM,E2_PREFIXO "
	cQry += " ,MAX(CASE WHEN RN=1  THEN E2_VENCTO END) VENC_01 "
	cQry += " ,MAX(CASE WHEN RN=2  THEN E2_VENCTO END) VENC_02 "
	cQry += " ,MAX(CASE WHEN RN=3  THEN E2_VENCTO END) VENC_03 "
	cQry += " ,MAX(CASE WHEN RN=4  THEN E2_VENCTO END) VENC_04 "
	cQry += " ,MAX(CASE WHEN RN=5  THEN E2_VENCTO END) VENC_05 "
	cQry += " ,MAX(CASE WHEN RN=6  THEN E2_VENCTO END) VENC_06 "
	cQry += " ,MAX(CASE WHEN RN=7  THEN E2_VENCTO END) VENC_07 "
	cQry += " ,MAX(CASE WHEN RN=8  THEN E2_VENCTO END) VENC_08 "
	cQry += " ,MAX(CASE WHEN RN=9  THEN E2_VENCTO END) VENC_09 "
	cQry += " ,MAX(CASE WHEN RN=10 THEN E2_VENCTO END) VENC_10 "
	cQry += " ,MAX(CASE WHEN RN=11 THEN E2_VENCTO END) VENC_11 "
	cQry += " ,MAX(CASE WHEN RN=12 THEN E2_VENCTO END) VENC_12 "
	cQry += " FROM ( "
	cQry += "   SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_NUM,E2_PREFIXO,E2_VENCTO "
	cQry += "        ,ROW_NUMBER() OVER (PARTITION BY E2_FILIAL,E2_FORNECE,E2_LOJA,E2_NUM,E2_PREFIXO "
	cQry += "                             ORDER BY E2_PARCELA) RN "
	cQry += "   FROM " + RetSqlName("SE2") + " WHERE D_E_L_E_T_='' "
	cQry += " ) T "
	cQry += " GROUP BY E2_FILIAL,E2_FORNECE,E2_LOJA,E2_NUM,E2_PREFIXO "
	cQry += ") TIT ON TIT.E2_FILIAL=SF1.F1_FILIAL AND TIT.E2_FORNECE=SF1.F1_FORNECE "
	cQry += " AND TIT.E2_LOJA=SF1.F1_LOJA AND TIT.E2_NUM=SF1.F1_DOC AND TIT.E2_PREFIXO=SF1.F1_SERIE "
	cQry += "WHERE SD1.D_E_L_E_T_='' "
	cQry += "AND D1_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
	cQry += "AND D1_DTDIGIT BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' "
	If !Empty(mv_par05) 
		cQry += "AND D1_CC = '"+mv_par05+"' "
	EndIf


	TcQuery cQry New Alias "QRY1"
	TCSetField("QRY1","EMISSAO","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","DTDIGIT","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_01","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_02","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_03","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_04","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_05","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_06","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_07","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_08","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_09","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_10","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_11","D",/*nSize*/,/*nPrecision*/)
	TCSetField("QRY1","VENC_12","D",/*nSize*/,/*nPrecision*/)
	// TCSetField("QRY1","C6_ENTREG","D",/*nSize*/,/*nPrecision*/)
	// TCSetField("QRY1","ZK_DATAFIM","D",/*nSize*/,/*nPrecision*/)

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
		_aStru := QRY1->(DbStruct())
		oExcel    := FWMSEXCEL():New()
		oExcel:AddworkSheet("ENTRADAS")
		oExcel:AddTable ("ENTRADAS","ENTRADAS")
		For _x := 1 to Len(_aStru)
			If _aStru[_x,2] == "N"
				oExcel:AddColumn("ENTRADAS","ENTRADAS",_aStru[_x,1],3,2)
			ElseIf _aStru[_x,2] == "D"
				oExcel:AddColumn("ENTRADAS","ENTRADAS",_aStru[_x,1],1,4)
			ElseIf _aStru[_x,2] == "C"
				If "/" $ _aStru[_x,1]
					oExcel:AddColumn("ENTRADAS","ENTRADAS",_aStru[_x,1],1,4)
				Else
					oExcel:AddColumn("ENTRADAS","ENTRADAS",_aStru[_x,1],1,1)
				EndIf
			EndIf
		Next

		While !QRY1->(Eof())
			IncProc("Gerando Excel....")
			_aLinha := Array(Len(_aStru))
			For _x := 1 To Len(_aStru)
				_cCpo := Alltrim(_aStru[_x,1])
				_aLinha[_x] := QRY1->&(_cCpo)
			Next

			oExcel:AddRow("ENTRADAS","ENTRADAS",_aLinha)
			QRY1->(DbSkip())
		EndDo
		oExcel:Activate()
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
		While File(_cFile)
			_cFile := (CriaTrab(NIL, .F.) + ".xml")
		EndDo
		oExcel:GetXMLFile(_cFile)
		oExcel:DeActivate()
		If !(File(_cFile))
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		_cFileTMP := (GetTempPath() + _cFile)
		If !(__CopyFile(_cFile , _cFileTMP))
			fErase( _cFile )
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		fErase(_cFile)
		_cFile := _cFileTMP
		If !(File(_cFile))
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(_cFile)
		oMsExcel:SetVisible(.T.)
		oMsExcel := oMsExcel:Destroy()

		FreeObj(oExcel)
		oExcel := NIL

	EndIf
	QRY1->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR235  บAutor  ณMicrosiga           บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()
	Local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg   := PADR(cPerg,10)
	aRegs   := {}
	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","De Filial      ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Filial     ?","","","mv_ch2","C",04,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"03","Data Inicial   ?","","","mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Data Final  ?","","","mv_ch4","D",08,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Centro de Custo ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
	//aAdd(aRegs,{cPerg,"02","At้ Data            ?","","","mv_ch2","D",08,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"03","Cliente de          ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CLI","","",""})
	//aAdd(aRegs,{cPerg,"04","Cliente ate         ?","","","mv_ch4","C",06,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CLI","","",""})
	//aAdd(aRegs,{cPerg,"03","Ordenar Por         ?","","","mv_ch3","C",01,0,0,"C","naovazio()","mv_par03","Quantitativo","","","","","Valorizado","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"04","Altera Msg do Boleto?","","","mv_che","C",01,0,0,"C","naovazio()","mv_par14","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"03","Prefixo            ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"04","Titulo de          ?","","","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"05","Titulo ate         ?","","","mv_ch5","C",09,0,0,"G","naovazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"06","Portador           ?","","","mv_ch6","C",03,0,0,"G","naovazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SEE","","",""})
	//aAdd(aRegs,{cPerg,"07","Agencia            ?","","","mv_ch7","C",05,0,0,"G","naovazio()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"08","Conta Corrente     ?","","","mv_ch8","C",10,0,0,"G","naovazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"09","Subconta           ?","","","mv_ch9","C",03,0,0,"G","naovazio()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"10","Cliente de         ?","","","mv_cha","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","CLI","","",""})
	//a/Add(aRegs,{cPerg,"11","Cliente ate        ?","","","mv_chb","C",06,0,0,"G","naovazio()","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","CLI","","",""})
	//aAdd(aRegs,{cPerg,"12","Filial             ?","","","mv_chc","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(_sAlias)

Return
