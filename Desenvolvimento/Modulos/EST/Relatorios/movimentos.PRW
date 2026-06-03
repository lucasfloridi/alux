#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#define _crlf chr(13)+Chr(10)
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

User Function RMTXD01()
    //Cria o MsApp
    MsApp():New('SIGAFAT')
    oApp:CreateEnv()
    //Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
    PtSetTheme("SUNSET")
    //Define o programa de inicializa็ใo
    oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
        {|| RpcSetEnv("01","0101"), }),;
        U_MTX001(),;
        Final("TERMINO NORMAL")}
    //Seta Atributos
    __lInternet := .T.
    lMsFinalAuto := .F.
    oApp:lMessageBar:= .T.
    oApp:cModDesc:= 'SIGAFAT'

    //Inicia a Janela
    oApp:Activate()
Return Nil

User Function MTX001
	cPerg := "MTX001"
	// __cInternet := NIL
	// RPCSetType(3)
	// Prepare Environment Empresa "01" Filial '0201' Tables "SA1","SF2" Modulo "EST"

	If !U_CheckAgent()
		REturn
	EndIf

	ValidPerg()
	If Pergunte(cPerg,.T.)
		// mv_par01 := stod("20250701")
		// mv_par02 := stod("20250731")
		// mv_par03 := ""
		// mv_par04 := "ZZZZ" //stod("20250731")
		//Processa({||Gera(),"Processando..."})
		Processa({||fGeraExcel(),"Processando..."})
		
	EndIf

Return

Static Function Gera()
	Local _x
	createView()
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
	cQry += "CREATE OR ALTER VIEW [dbo].[V_MOVIMENTOS] " + _crlf
	cQry += "AS " + _crlf
	cQry += "SELECT        'ESTOQUE' MODULO, D3_FILIAL AS FILIAL, 'SD3' ORIGEM, CASE WHEN D3_TM < '500' THEN 'E' ELSE 'S' END AS 'ES', '' TIPODOC, D3_DOC DOCUMENTO,ISNULL(C2_RECURSO,'') RECURSO,D3_OP OP,ISNULL(C2_BATROT,'') ROTINA,ISNULL(C2_LOCAL,'') LOCAL_OP" + _crlf
	cQry += ",'' CLIFOR, '' NOME, D3_NUMSEQ SEQUEN,D3_SEQCALC SEQCALC " + _crlf
	cQry += ",CONVERT(DATE,D3_EMISSAO) DT_EMISSAO, D3_EMISSAO AS EMISSAO, D3_LOCAL AS 'LOCAL', D3_TM TES, ISNULL(F5_VAL, '-') VALORIZADO, 'S' AS ESTOQUE, D3_COD PRODUTO, B1_DESC DESCRIC,B1_CONTA CONTA, B1_POSIPI NCM  " + _crlf
	cQry += ",B1_TIPO TIPO, D3_UM UM, D3_LOTECTL LOTE, CASE WHEN D3_TM < 500 THEN D3_QUANT ELSE - D3_QUANT END QUANTIDADE,D3_QTSEGUM QTSEGUM, D3_CF CFO  " + _crlf
	cQry += ",CASE WHEN D3_TM <= '499' THEN 1 ELSE - 1 END * D3_CUSTO1 CUSTO,IIF(D3_QUANT>0,D3_CUSTO1/D3_QUANT,0) CM_UNITARIO, D3_CUSTO1 AS TOTAL, 0 AS DESPESA, 0 AS FRETE, 0 AS VALPIS, 0 AS VALCOF, 0 AS VALICM, 0 AS VALIPI  " + _crlf
    If cFilAnt=="0101"
         cQry += ",SD3.R_E_C_N_O_ REGISTRO,  '' TIPO_DOC ,'' TICKET,'' NFORIG,'' SERIE_ORI " + _crlf
    Else
        cQry += ",SD3.R_E_C_N_O_ REGISTRO,  '' TIPO_DOC ,ISNULL(C2_XCODSZ2,D3_XCODSZ2) TICKET,'' NFORIG,'' SERIE_ORI " + _crlf
    EndIf
	cQry += "FROM SD3010 SD3  " + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D3_FILIAL,1,2) AND B1_COD = D3_COD " + _crlf
	cQry += "	LEFT JOIN SF5010 SF5 ON SF5.D_E_L_E_T_ ='' AND F5_FILIAL=D3_FILIAL AND F5_CODIGO = D3_TM  " + _crlf
	cQry += "	LEFT JOIN SC2010 SC2 ON SC2.D_E_L_E_T_ ='' AND C2_FILIAL=D3_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D3_OP  " + _crlf
	// cQry += "	LEFT JOIN SH6010 SH6 ON SH6.D_E_L_E_T_='' AND D3_FILIAL=H6_FILIAL AND D3_OP=H6_OP AND D3_IDENT=H6_IDENT " + _crlf
	cQry += "WHERE        SD3.D_E_L_E_T_ ='' AND D3_ESTORNO <> 'S' " + _crlf
	cQry += "UNION ALL " + _crlf
	cQry += "SELECT        CASE D1_TIPO WHEN 'D' THEN 'DEVOLUCAO DE VENDAS' ELSE 'COMPRAS' END MODULO, D1_FILIAL, 'SD1' ORIGEM, F4_TIPO AS ES, D1_TIPO TIPODOC, D1_DOC,'' RECURSO,'' OP ,'' ROTINA,'' LOCAL_OP " + _crlf
	cQry += ",D1_FORNECE CLIFOR,CASE D1_TIPO WHEN 'D' THEN A1_NOME WHEN 'B' THEN A1_NOME ELSE A2_NOME END NOME, D1_NUMSEQ,D1_SEQCALC SEQCALC, CONVERT(DATE, D1_DTDIGIT) DT_EMISSAO, D1_DTDIGIT AS EMISSAO, D1_LOCAL, D1_TES  " + _crlf
	cQry += ",F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE, D1_COD, B1_DESC DESCRIC,B1_CONTA CONTA, B1_POSIPI NCM, B1_TIPO, D1_UM, D1_LOTECTL LOTE, D1_QUANT,D1_QTSEGUM QTSEGUM, D1_CF, D1_CUSTO,IIF(D1_QUANT>0,D1_CUSTO/D1_QUANT,0) CM_UNITARIO, D1_TOTAL AS TOTAL, D1_DESPESA  " + _crlf
	If cFilAnt == "0101"
        cQry += ",D1_VALFRE, D1_VALIMP6 AS VALPIS, D1_VALIMP5 AS VALCOF, D1_VALICM AS VALICM, D1_VALIPI AS VALIPI, SD1.R_E_C_N_O_,  D1_TIPO TIPO_DOC,'' TICKET,D1_DOC NFORIG, D1_SERIE SERIE_ORI  " + _crlf
    Else
        cQry += ",D1_VALFRE, D1_VALIMP6 AS VALPIS, D1_VALIMP5 AS VALCOF, D1_VALICM AS VALICM, D1_VALIPI AS VALIPI, SD1.R_E_C_N_O_,  D1_TIPO TIPO_DOC,D1_XCODSZ2 TICKET,D1_DOC NFORIG, D1_SERIE SERIE_ORI  " + _crlf
    EndIf
    cQry += "FROM SD1010 SD1  " + _crlf
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_FILIAL=D1_FILIAL AND F4_CODIGO = D1_TES  " + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D1_FILIAL,1,2) AND B1_COD = D1_COD  " + _crlf
	cQry += "	LEFT OUTER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA  " + _crlf
	cQry += "	LEFT OUTER JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA  " + _crlf
	cQry += "WHERE        SD1.D_E_L_E_T_ ='' " + _crlf
	cQry += "UNION ALL " + _crlf
	cQry += "SELECT        CASE D2_TIPO WHEN 'D' THEN 'DEVOLUCAO DE COMPRAS' ELSE 'VENDA' END MODULO, D2_FILIAL, 'SD2' ORIGEM, F4_TIPO AS ES, D2_TIPO TIPODOC, D2_DOC,'' RECURSO, '' OP, '' ROTINA,'' LOCAL_OP " + _crlf
	cQry += ",D2_CLIENTE CLIFOR,CASE D2_TIPO WHEN 'D' THEN A2_NOME WHEN 'F' THEN A2_NOME ELSE A1_NOME END NOME, D2_NUMSEQ,D2_SEQCALC SEQCALC, CONVERT(DATE, D2_EMISSAO) DT_EMISSAO, D2_EMISSAO AS EMISSAO, D2_LOCAL, D2_TES  " + _crlf
	cQry += ",F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE, D2_COD, B1_DESC DESCRIC,B1_CONTA CONTA, B1_POSIPI NCM, B1_TIPO, D2_UM, D2_LOTECTL LOTE, - D2_QUANT,D2_QTSEGUM QTSEGUM, D2_CF, D2_CUSTO1 * - 1,IIF(D2_QUANT>0,D2_CUSTO1/D2_QUANT,0) CM_UNITARIO, D2_TOTAL AS TOTAL  " + _crlf
	If cFilAnt == "0101"
        cQry += ",D2_DESPESA, D2_VALFRE, D2_VALIMP6 AS VALPIS, D2_VALIMP5 AS VALCOF, D2_VALICM AS VALICM, D2_VALIPI AS VALIPI, SD2.R_E_C_N_O_,  D2_TIPO TIPO_DOC,'' TICKET,D2_NFORI NFORIG,D2_SERIORI SERIE_ORI " + _crlf
    Else
        cQry += ",D2_DESPESA, D2_VALFRE, D2_VALIMP6 AS VALPIS, D2_VALIMP5 AS VALCOF, D2_VALICM AS VALICM, D2_VALIPI AS VALIPI, SD2.R_E_C_N_O_,  D2_TIPO TIPO_DOC,D2_XCODSZ2 TICKET,D2_NFORI NFORIG,D2_SERIORI SERIE_ORI " + _crlf
    EndIf
	
    cQry += "FROM            SD2010 SD2  " + _crlf
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_CODIGO = D2_TES AND F4_FILIAL=D2_FILIAL" + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_COD = D2_COD AND B1_FILIAL=SUBSTRING(D2_FILIAL,1,2) " + _crlf
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



Static Function fGeraExcel()
    Local aArea       := FWGetArea()
    Local oPrintXlsx
    Local dData       := Date()
    Local cHora       := Time()
    Local cCodUsr     := RetCodUsr()
    Local cArquivo    := GetTempPath() + 'RelMovimentos' + dToS(dData) + '_' + StrTran(cHora, ':', '-') + '.rel'
    Local cLogo       := ""
    Local cConteudo   := ""
    Local oFileRead
    Local cQryDad     := ""
    Local nAtual      := 0
    Local nTotal      := 0
    Local aCampos     := {}
    Local aColunas    := {}
    Local oExcel
    Local cFonte      := FwPrinterFont():Arial()
    Local nTamFonte   := 12
    Local lItalico    := .F.
    Local lNegrito    := .T.
    Local lSublinhado := .F.
    Local nCpoAtual   := 0
    Local oCellHoriz  := FwXlsxCellAlignment():Horizontal()
    Local oCellVerti  := FwXlsxCellAlignment():Vertical()
    Local cHorAlinha  := ""
    Local cVerAlinha  := ""
    Local lQuebrLin   := .F.
    Local nRotation   := 0
    Local cCustForma  := ""
    Local cCampoAtu   := ""
    Local cTipo       := ""
    Local nTamanho    := 0
    Local cTitulo     := ""
    Local cMascara    := ""
    Local cCorFundo   := ""
 
    createView()
	
	cQry := " SELECT * "
	cQry += " FROM V_MOVIMENTOS "
	cQry += " WHERE FILIAL BETWEEN '"+(MV_PAR03) +"' AND '"+(MV_PAR04)+"' "
	cQry += " AND DT_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"' "
     
    //Executando consulta e setando o total da regua
    PlsQuery(cQry, "QRY_DAD")
    DbSelectArea("QRY_DAD")
 
    //Somente se houver dados
    If ! QRY_DAD->(EoF())
 
        //Definindo o tamanho da regua
        Count To nTotal
        ProcRegua(nTotal)
        QRY_DAD->(DbGoTop())
        aCampos := QRY_DAD->(DbStruct())
 
        //Vamos percorrer os campos e montar a estrutura das colunas
        For nAtual := 1 To Len(aCampos)
            cCampoAtu := aCampos[nAtual][1]
            cTipo     := aCampos[nAtual][2]
            nTamanho  := aCampos[nAtual][3]
            cTitulo   := aCampos[nAtual][1] //Alltrim(GetSX3Cache(cCampoAtu, "X3_TITULO"))
            cMascara  := ""
 
            //Se o tํtulo tiver vazio, pega do nome do campo mesmo
            If Empty(cTitulo)
                cTitulo := Alltrim(cCampoAtu)
            EndIf
 
            //Se for data, vai ser centralizado
            If cTipo == "D"
                nAlinhamento := 2
 
            //Se for num้rico, vai ser a direita
            ElseIf cTipo == "N"
                nAlinhamento := 1
 
                //Busca a mแscara do campo, caso nใo encontre, monta mแscara manual
                cMascara := ""//Alltrim(GetSX3Cache(cCampoAtu, "X3_PICTURE"))
                If Empty(cMascara)
                    cMascara := "@E 999,999,999.99"
                EndIf
 
            //Senใo, por default (caractere, memo, outros) serแ a esquerda
            Else
                nAlinhamento := 0
            EndIf
 
            //Se o texto do tํtulo for maior que o tamanho da coluna, muda a variแvel
            If Len(cTitulo) > nTamanho
                nTamanho := Len(cTitulo)
            EndIf
 
            aAdd(aColunas, {;
                cTitulo,;        //01 - Tํtulo do Campo no dicionแrio
                nTamanho * 1.5,; //02 - Largura em pixels usada no Excel
                nAlinhamento,;   //03 - Alinhamento (0=Esquerda, 1=Direita, 2=Centralizado)
                cMascara;        //04 - Mแscara, em caso de campos num้ricos
            })
        Next
     
        //Instancia a classe, e tenta criar o arquivo .rel
        oPrintXlsx := FwPrinterXlsx():New()
        If oPrintXlsx:Activate(cArquivo)
 
            //Adiciona uma worksheet
            oPrintXlsx:AddSheet("Movimentos")
 
            //Agora vamos ler o logo e pegar o conte๚do dele
            /*cLogo := "\x_imagens\logo.png"
            oFileRead := FwFileReader():New(cLogo)
            If oFileRead:Open()
                cConteudo  := oFileRead:FullRead()
            EndIf

            oFileRead:Close()
			
            //Vamos colocar o logo na linha 1, coluna 1 e vamos redimensionar deixando 64 de largura por 64 de altura
            oPrintXlsx:AddImageFromBuffer(1, 1, "logo", cConteudo, 64, 64)
			*/
            //Vamos definir a fonte padrใo usada como Arial
            oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
 
            //Agora vamos colocar algumas informa็๕es resumidas no cabe็alho (todos na coluna 3)
            // oPrintXlsx:SetText(1, 3, "Fonte: Relat๓prio de Movimentos")
            // oPrintXlsx:SetText(2, 3, "Data: "    + dToC(dData))
            // oPrintXlsx:SetText(3, 3, "Hora: "    + cHora)
            // oPrintXlsx:SetText(4, 3, "Usuแrio: " + cCodUsr + " - " + UsrRetName(cCodUsr))
 
            //Depois de imprimir os textos do cabe็alho, vamos colocar a fonte como normal
            nTamFonte := 10
            lNegrito  := .F.
            oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
             
            //Na primeira linha do cabe็alho, vamos definir como tudo centralizado, a cor do texto verde e de fundo branca
            cHorAlinha  := oCellHoriz:Center()
            cVerAlinha  := oCellVerti:Center()
            oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, "22B14C", "FFFFFF", cCustForma)
 
            //Percorre agora as colunas e vem setando o tamanho delas e colocando o nome
            nLinExcel := 1
            For nAtual := 1 To Len(aColunas)
                oPrintXlsx:SetColumnsWidth(nAtual, nAtual, aColunas[nAtual][2])
                oPrintXlsx:SetText(nLinExcel, nAtual, aColunas[nAtual][1])
            Next
 
            //Define que as colunas terใo op็ใo de filtrar (da coluna 1 at้ a quantidade de campos)
            oPrintXlsx:ApplyAutoFilter(nLinExcel, 1, nLinExcel, Len(aCampos))
             
            //Percorrendo os dados da query
            nAtual := 0
            While !(QRY_DAD->(EoF()))
                 
                //Incrementando a regua
                nAtual++
                IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
 
                //Se for ํmpar, o fundo vai ser verde claro, senใo vai ser branco
                If nAtual % 2 != 0
                    cCorFundo := "EBF1DE"
                Else
                    cCorFundo := "FFFFFF"
                EndIf
 
                //Incrementa a linha no Excel
                nLinExcel++
 
                //Percorre as colunas
                For nCpoAtual := 1 To Len(aCampos)
                    cCampoAtu := aCampos[nCpoAtual][1]
                    cTipo     := aCampos[nCpoAtual][2]
                    xConteud  := &("QRY_DAD->" + cCampoAtu)
 
                    //Se for data, vai ser centralizado
                    If cTipo == "D"
                        xConteud := dToC(xConteud)
 
                    //Se for num้rico, vai ser a direita
                    ElseIf cTipo == "N"
                        //Se tem mแscara, aplica num transform
                        /*If ! Empty(aColunas[nCpoAtual][4])
                            xConteud := Alltrim(Transform(xConteud, aColunas[nCpoAtual][4]))
 
                        //Senใo converte de num้rico para texto
                        Else
                            xConteud := cValToChar(xConteud)
                        EndIf*/
                        
                    //Senใo, apenas tira espa็os do campo
                    Else
                        xConteud := Alltrim(xConteud)
                    EndIf
 
                    //Se o alinhamento for a direita
                    If aColunas[nCpoAtual][3] == 1
                        cHorAlinha := oCellHoriz:Right()
 
                    //Se for centralizado
                    ElseIf aColunas[nCpoAtual][3] == 2
                        cHorAlinha := oCellHoriz:Center()
 
                    //Senใo, serแ a esquerda
                    Else
                        cHorAlinha := oCellHoriz:Left()
                    EndIf
 
                    //Reseta a formata็ใo
                    oPrintXlsx:ResetCellsFormat()
 
                    //Em seguida, define a formata็ใo da coluna, sendo que o texto serแ preto
                    oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, "000000", cCorFundo, cCustForma)
                     
                    If cTipo == "N"
                        //Define a formata็ใo num้rica para a c้lula
                        //oPrintXlsx:SetCellNumberFormat(nLinExcel, nCpoAtual, "#,##0.00")
                        oPrintXlsx:SetNumber(nLinExcel, nCpoAtual, xConteud) 
                    Else
                        //Adiciona a informa็ใo na linha do excel na coluna do campo
                        oPrintXlsx:SetText(nLinExcel, nCpoAtual, xConteud)
                    EndIf
                Next
                 
                QRY_DAD->(DbSkip())
            EndDo
 
            //Vamos finalizar o arquivo
            oPrintXlsx:ToXlsx()
            oPrintXlsx:DeActivate()
 
            //E agora vamos abrir ele
            cArquivo := ChgFileExt(cArquivo, ".xlsx")
            If File(cArquivo)
                oExcel := MsExcel():New()
                oExcel:WorkBooks:Open(cArquivo)
                oExcel:SetVisible(.T.)
                oExcel:Destroy()
            EndIf
        EndIf
 
    Else
        FWAlertError("Nใo foi encontrado registros com os filtros informados!", "Falha")
    EndIf
    QRY_DAD->(DbCloseArea())
     
    FWRestArea(aArea)    
Return
