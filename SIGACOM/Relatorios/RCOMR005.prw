#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#Define _crlf Chr(13)+Chr(10)

/*/{Protheus.doc} RCOMRD05
Chamada em job / agent: monta o ambiente (MsApp / SIGACOM) e dispara a rotina
de geracao do relatorio de escrituracao pendente (U_RCOMR005).

@type    function
@author  Lucas Floridi Leme
@since   02/10/14
@return  Variant, retorno sempre Nil
/*/
User Function RCOMRD05()
	//Cria o MsApp
	MsApp():New('SIGACOM')
	oApp:CreateEnv()
	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")
	//Define o programa de inicializacao
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
		{|| RpcSetEnv("01","0201"), }),;
		U_RCOMR005(),;
		Final("TERMINO NORMAL")}
	//Seta Atributos
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGACOM'

	//Inicia a Janela
	oApp:Activate()
Return Nil

/*/{Protheus.doc} RCOMR005
Rotina principal do relatorio de escrituracao pendente. Valida o grupo de
perguntas (SX1), exibe a tela de parametros e dispara a geracao.

@type    function
@author  Lucas Floridi Leme
@since   02/10/14
@return  Variant, retorno sempre Nil
/*/
User Function RCOMR005()
	cPerg := "RCOMR005"
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

/*/{Protheus.doc} Gera
Monta a consulta da escrituracao pendente (CKOCOL x SDS010 x SDT010),
desconsiderando os documentos ja escriturados (SF1) e os marcados com ciencia
de desconsideracao no monitor (DS_XCIENC = 1), e gera a planilha em Excel
(FWMSEXCEL).

@type    function
@author  Lucas Floridi Leme
@since   02/10/14
@return  Variant, retorno sempre Nil
/*/
Static Function Gera()
	Local _x := 0
	// createView()

	cQry := "SELECT CKO_FILPRO FILIAL"
	cQry += ",CASE WHEN CKO_CODEDI IN ('109','214') THEN '20'+SUBSTRING(CKO_CHVDOC,3,2)+'-'+SUBSTRING(CKO_CHVDOC,5,2) ELSE SUBSTRING(CKO_CHVDOC,1,7) END PERIODO"
	cQry += ",CASE CKO_CODEDI WHEN '109' THEN 'SPED' WHEN '214' THEN 'CTE' WHEN '319' THEN 'NFSE' WHEN '273' THEN 'CTEOS' ELSE CKO_CODEDI END ESPECIE "
	cQry += ",CKO_CHVDOC CHAVE,CKO_NOMFOR NOME, CKO_DOC DOC,CKO_SERIE,CKO_FLAG FLAG "
	cQry += ",CKO_CODERR COD_ERR,' ' DESC_ERRO"
	cQry += ",SUBSTRING(CKO_CHVDOC,7,14) CNPJ_EMIT "
	cQry += ",CONVERT(DATE,DS_EMISSA) EMISSAO,DS_STATUS STATUS,DS_CNPJ CNPJ_EMISSOR "
	cQry += ",DT_ITEM ITEM,DT_PRODFOR ID_PROD_FOR,DT_CODCFOP CFOP,DT_DESCFOR DESC_PROD,DT_QUANT QUANTIDADE,DT_VUNIT VUNIT,DT_TOTAL VAL_MERC "
	cQry += "FROM CKOCOL CKO "
	cQry += "  LEFT JOIN SDS010 SDS ON SDS.D_E_L_E_T_='' AND (CKO_ARQUIV=DS_ARQUIVO OR DS_CHAVENF=CKO_CHVDOC) "
	cQry += "  LEFT JOIN SDT010 SDT ON SDT.D_E_L_E_T_='' AND DT_FILIAL=DS_FILIAL AND DT_DOC=DS_DOC AND DT_FORNEC=DS_FORNEC AND DT_LOJA=DS_LOJA "
	cQry += "WHERE CKO.D_E_L_E_T_='' "
	cQry += "AND NOT EXISTS (SELECT 1 FROM SF1010 SF1 WHERE SF1.D_E_L_E_T_='' AND F1_CHVNFE=CKO_CHVDOC) "
	// Desconsidera documentos marcados com ciencia de desconsideracao no monitor (DS_XCIENC=1)
	cQry += "AND (SDS.DS_XCIENC IS NULL OR SDS.DS_XCIENC <> '1') "
	cQry += " "
	If !funname() == "RPC"
		cQry += "AND CKO_FILPRO BETWEEN '"+(mv_par01)+"' AND '"+(MV_PAR02)+"' "
	EndIf
	// cQry += "AND D1_DTDIGIT BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(MV_PAR04)+"' "

	TcQuery cQry New Alias "QRY1"
	TCSetField("QRY1","EMISSAO","D",/*nSize*/,/*nPrecision*/)
	// TCSetField("QRY1","DTDIGIT","D",/*nSize*/,/*nPrecision*/)
	// TCSetField("QRY1","C6_ENTREG","D",/*nSize*/,/*nPrecision*/)
	// TCSetField("QRY1","ZK_DATAFIM","D",/*nSize*/,/*nPrecision*/)

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
		_aStru := QRY1->(DbStruct())
		oExcel    := FWMSEXCEL():New()
		oExcel:AddworkSheet("ESCRITURACAO_PENDENTE")
		oExcel:AddTable ("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE")
		For _x := 1 to Len(_aStru)
			If _aStru[_x,2] == "N"
				oExcel:AddColumn("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE",_aStru[_x,1],3,2)
			ElseIf _aStru[_x,2] == "D"
				oExcel:AddColumn("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE",_aStru[_x,1],1,4)
			ElseIf _aStru[_x,2] == "C"
				If "/" $ _aStru[_x,1]
					oExcel:AddColumn("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE",_aStru[_x,1],1,4)
				Else
					oExcel:AddColumn("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE",_aStru[_x,1],1,1)
				EndIf
			EndIf
		Next

		While !QRY1->(Eof())
			IncProc("Gerando Excel....")
			_aLinha := Array(Len(_aStru))
			For _x := 1 To Len(_aStru)
				_cCpo := Alltrim(_aStru[_x,1])
				If _cCpo == "DESC_ERRO"
					_aLinha[_x] := ColErroErp(QRY1->COD_ERR)
				Else
					_aLinha[_x] := QRY1->&(_cCpo)
				EndIf
			Next

			oExcel:AddRow("ESCRITURACAO_PENDENTE","ESCRITURACAO_PENDENTE",_aLinha)
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

/*/{Protheus.doc} ValidPerg
Cria / valida o grupo de perguntas (SX1) utilizado pelo relatorio RCOMR005.

@type    function
@author  Lucas Floridi Leme
@since   10/02/14
@return  Variant, retorno sempre Nil
/*/
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
	// aAdd(aRegs,{cPerg,"03","Data Inicial   ?","","","mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	// aAdd(aRegs,{cPerg,"04","Data Final  ?","","","mv_ch4","D",08,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"02","Grupo de Produtos       ?","","","mv_ch2","C",04,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","",""})
	//aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
