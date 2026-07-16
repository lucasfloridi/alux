#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
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
User Function MOV_ES_001
	cPerg := "MTX001"
	// __cInternet := NIL
	// RPCSetType(3)
	// Prepare Environment Empresa "01" Filial '0201' Tables "SA1","SF2" Modulo "EST"

	ValidPerg()
	If Pergunte(cPerg,.T.)
		// mv_par01 := stod("20250701")
		// mv_par02 := stod("20250731")
		// mv_par03 := ""
		// mv_par04 := "ZZZZ" //stod("20250731")
		Processa({||Gera(),"Processando..."})
	EndIf

Return

Static Function Gera()
	Local _x
	// createView()
	cQry := " SELECT * "
	cQry += " FROM V_MOVIMENTOS "
	cQry += " WHERE FILIAL BETWEEN '"+(MV_PAR03) +"' AND '"+(MV_PAR04)+"' "
	// cQry += "AND CONVERT(CHAR(8),EMISSAO,112) BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"' "
	cQry += " AND DT_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"' "


	TcQuery cQry New Alias "QRY1"

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
		_aStru := QRY1->(DbStruct())
		oExcel    := FWMSEXCEL():New()
		oExcel:AddworkSheet("MOVIMENTOS")
		oExcel:AddTable ("MOVIMENTOS","MOVIMENTOS")
		For _x := 1 to Len(_aStru)
			If _aStru[_x,2] == "N"
				oExcel:AddColumn("MOVIMENTOS","MOVIMENTOS",_aStru[_x,1],3,2)
			ElseIf _aStru[_x,2] == "D"
				oExcel:AddColumn("MOVIMENTOS","MOVIMENTOS",_aStru[_x,1],1,4)
			ElseIf _aStru[_x,2] == "C"
				If "/" $ _aStru[_x,1]
					oExcel:AddColumn("MOVIMENTOS","MOVIMENTOS",_aStru[_x,1],1,4)
				Else
					oExcel:AddColumn("MOVIMENTOS","MOVIMENTOS",_aStru[_x,1],1,1)
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

			oExcel:AddRow("MOVIMENTOS","MOVIMENTOS",_aLinha)
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
	aAdd(aRegs,{cPerg,"01","Data Inicial   ?","","","mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Final  ?","","","mv_ch2","D",08,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Filial      ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Filial     ?","","","mv_ch4","C",04,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
//aAdd(aRegs,{cPerg,"02","Grupo de Produtos       ?","","","mv_ch2","C",04,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","",""})
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


static function createView()

	local cQry := ""
	cQry += "CREATE OR ALTER VIEW [dbo].[V_MOVIMENTOS] "
	cQry += "AS "
	cQry += "SELECT        'ESTOQUE' MODULO, D3_FILIAL AS FILIAL, 'SD3' ORIGEM, CASE WHEN D3_TM < '500' THEN 'E' ELSE 'S' END AS 'ES', '' TIPODOC, D3_DOC DOCUMENTO,D3_OP OP, '' NOME, D3_NUMSEQ SEQUEN, CONVERT(DATE,  "
	cQry += "                         D3_EMISSAO) DT_EMISSAO, D3_EMISSAO AS EMISSAO, D3_LOCAL AS 'LOCAL', D3_TM TES, ISNULL(F5_VAL, '-') VALORIZADO, 'S' AS ESTOQUE, D3_COD PRODUTO, B1_DESC DESCRIC, B1_POSIPI NCM,  "
	cQry += "                         B1_TIPO TIPO, D3_UM UM, D3_LOTECTL LOTE, CASE WHEN D3_TM < 500 THEN D3_QUANT ELSE - D3_QUANT END QUANTIDADE, D3_CF CFO,  "
	cQry += "                         CASE WHEN D3_TM <= '499' THEN 1 ELSE - 1 END * D3_CUSTO1 CUSTO, D3_CUSTO1 AS TOTAL, 0 AS DESPESA, 0 AS FRETE, 0 AS VALPIS, 0 AS VALCOF, 0 AS VALICM, 0 AS VALIPI,  "
	cQry += "                         SD3.R_E_C_N_O_ REGISTRO,  '' TIPO_DOC ,ISNULL(C2_XCODSZ2,D3_XCODSZ2) TICKET "
	cQry += "FROM SD3010 SD3  "
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D3_FILIAL,1,2) AND B1_COD = D3_COD "
	cQry += "	LEFT OUTER JOIN SF5010 SF5 ON SF5.D_E_L_E_T_ ='' AND F5_FILIAL=D3_FILIAL AND F5_CODIGO = D3_TM  "
	cQry += "	LEFT OUTER JOIN SC2010 SC2 ON SC2.D_E_L_E_T_ ='' AND C2_FILIAL=D3_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D3_OP  "
	cQry += "WHERE        SD3.D_E_L_E_T_ ='' AND D3_ESTORNO <> 'S' "
	cQry += "UNION ALL "
	cQry += "SELECT        CASE D1_TIPO WHEN 'D' THEN 'DEVOLUCAO DE VENDAS' ELSE 'COMPRAS' END MODULO, D1_FILIAL, 'SD1' ORIGEM, F4_TIPO AS ES, D1_TIPO TIPODOC, D1_DOC,'' OP , "
	cQry += "                         CASE D1_TIPO WHEN 'D' THEN A1_NOME WHEN 'B' THEN A1_NOME ELSE A2_NOME END NOME, D1_NUMSEQ, CONVERT(DATE, D1_DTDIGIT) DT_EMISSAO, D1_DTDIGIT AS EMISSAO, D1_LOCAL, D1_TES,  "
	cQry += "                         F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE, D1_COD, B1_DESC DESCRIC, B1_POSIPI NCM, B1_TIPO, D1_UM, D1_LOTECTL LOTE, D1_QUANT, D1_CF, D1_CUSTO, D1_TOTAL AS TOTAL, D1_DESPESA,  "
	cQry += "                         D1_VALFRE, D1_VALIMP6 AS VALPIS, D1_VALIMP5 AS VALCOF, D1_VALICM AS VALICM, D1_VALIPI AS VALIPI, SD1.R_E_C_N_O_,  D1_TIPO TIPO_DOC,D1_XCODSZ2 TICKET "
	cQry += "FROM SD1010 SD1  "
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_FILIAL=SUBSTRING(D1_FILIAL,1,2) AND F4_CODIGO = D1_TES  "
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D1_FILIAL,1,2) AND B1_COD = D1_COD  "
	cQry += "	LEFT OUTER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA AND SUBSTRING(D1_FILIAL,1,2)=A1_FILIAL "
	cQry += "	LEFT OUTER JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SUBSTRING(D1_FILIAL,1,2)=A2_FILIAL "
	cQry += "WHERE        SD1.D_E_L_E_T_ ='' "
	cQry += "UNION ALL "
	cQry += "SELECT        CASE D2_TIPO WHEN 'D' THEN 'DEVOLUCAO DE COMPRAS' ELSE 'VENDA' END MODULO, D2_FILIAL, 'SD2' ORIGEM, F4_TIPO AS ES, D2_TIPO TIPODOC, D2_DOC, '' OP, "
	cQry += "                         CASE D2_TIPO WHEN 'D' THEN A2_NOME WHEN 'F' THEN A2_NOME ELSE A1_NOME END NOME, D2_NUMSEQ, CONVERT(DATE, D2_EMISSAO) DT_EMISSAO, D2_EMISSAO AS EMISSAO, D2_LOCAL, D2_TES,  "
	cQry += "                         F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE, D2_COD, B1_DESC DESCRIC, B1_POSIPI NCM, B1_TIPO, D2_UM, D2_LOTECTL LOTE, - D2_QUANT, D2_CF, D2_CUSTO1 * - 1, D2_TOTAL AS TOTAL,  "
	cQry += "                         D2_DESPESA, D2_VALFRE, D2_VALIMP6 AS VALPIS, D2_VALIMP5 AS VALCOF, D2_VALICM AS VALICM, D2_VALIPI AS VALIPI, SD2.R_E_C_N_O_,  D2_TIPO TIPO_DOC,D2_XCODSZ2 TICKET "
	cQry += "FROM            SD2010 SD2  "
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_CODIGO = D2_TES AND F4_FILIAL=SUBSTRING(D2_FILIAL,1,2) "
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_COD = D2_COD AND B1_FILIAL=SUBSTRING(D2_FILIAL,1,2) "
	cQry += "	LEFT OUTER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND SUBSTRING(D2_FILIAL,1,2)=A1_FILIAL "
	cQry += "	LEFT OUTER JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD = D2_CLIENTE AND A2_LOJA = D2_LOJA AND SUBSTRING(D2_FILIAL,1,2)=A2_FILIAL "
	cQry += "WHERE        SD2.D_E_L_E_T_ ='' "

	If TcSqlExec(cQry) < 0
		FWAlertError(TCSQLError())
	EndIF

Return
