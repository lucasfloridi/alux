#include "totvs.ch"
#include 'fwcommand.ch'

/*/{Protheus.doc} User Function RelPesBal
	Relatório de pesagens da balança.
	@type  Function
	@author Diogo Mesquita
	@since 13/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function RelPesBal()
    
	Local bParams		:= {|| oParamBox:show()  }
	Local bProcRel		:= {|| procRel() }
	
	Private cTicketDe	:= ""
	Private cTicketAte	:= ""
	Private dDtPeInDe	:= CtoD("")
	Private dDtPeInAte	:= CtoD("")
	Private dDtPeFiDe	:= CtoD("")
	Private dDtPeFiAte	:= CtoD("")
	Private cItemDe		:= ""
	Private cItemAte	:= ""
	Private cJaUtilizados := ""

	Private cNome  		:= "RelPesBal"
	Private cTitulo 	:= "Relatório de Pesagens da Balança"
	Private cDescricao	:= "Imprime o relatório de pesagens da balança"
	
	Private oReport		:= Nil
	Private oSection	:= Nil
	 	
	Private oBreak		:= Nil
	Private oParamBox 	:= IpParamBoxObject():newIpParamBoxObject(cNome)
	
	Private oSql		:= Nil
	Private cAlias		:= ""
	
	criaParams()

	oReport := TReport():new(cNome, cTitulo, bParams, bProcRel, cDescricao)
	
	criaSecao()

	oReport:setLandscape()
	oReport:printDialog()
        
Return

/*/{Protheus.doc} criaParams
	Leitura dos parâmetros.
	@type  Static Function
	@author Diogo Mesquita
	@since 13/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function criaParams()
	
	Local oParam := Nil
	
	oParamBox:setTitle(cTitulo)
	
	oParam := IpParamObject():newIpParamObject("ticketDe", "get", "Ticket de", "C", 60, TamSX3("ZZ1_SEQUEN")[1])
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("ticketAte", "get", "Ticket até", "C", 60, TamSX3("ZZ1_SEQUEN")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("dataPesoInicialDe", "get", "Dt. Peso Inicial de", "D", 60, TamSX3("ZZ1_DTPEIN")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("dataPesoInicialAte", "get", "Dt. Peso Inicial até", "D", 60, TamSX3("ZZ1_DTPEIN")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("dataPesoFinalDe", "get", "Dt. Peso Final de", "D", 60, TamSX3("ZZ1_DTPEFI")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("dataPesoFinalAte", "get", "Dt. Peso Final até", "D", 60, TamSX3("ZZ1_DTPEFI")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("itemDe", "get", "Item de", "C", 60, TamSX3("ZZ1_CODITE")[1])
	oParamBox:addParam(oParam)
	
	oParam := IpParamObject():newIpParamObject("itemAte", "get", "Item até", "C", 60, TamSX3("ZZ1_CODITE")[1])
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)

	oParam := IpParamObject():newIpParamObject("jaUtilizados", "combo", "Já utilizados?", "C", 60)
	oParam:setValues({"Sim","Não","Ambos"}) 
	oParamBox:addParam(oParam)
	
Return


/*/{Protheus.doc} procRel
	Processamento do relatório.
	@type  Static Function
	@author Diogo Mesquita
	@since 13/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function procRel()

	cTicketDe	:= oParamBox:getValue("ticketDe")
	cTicketAte	:= oParamBox:getValue("ticketAte")
	dDtPeInDe	:= oParamBox:getValue("dataPesoInicialDe")
	dDtPeInAte	:= oParamBox:getValue("dataPesoInicialAte")
	dDtPeFiDe	:= oParamBox:getValue("dataPesoFinalDe")
	dDtPeFiAte	:= oParamBox:getValue("dataPesoFinalAte")
	cItemDe		:= oParamBox:getValue("itemDe")
	cItemAte	:= oParamBox:getValue("itemAte")
	cJaUtilizados:= oParamBox:getValue("jaUtilizados")

	getDadosRel()
	procImpressao()
	
Return

/*/{Protheus.doc} criaSecao
	Cria as seções do relatório.
	@type  Static Function
	@author Diogo Mesquita
	@since 14/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function criaSecao()
	
	local aOrdem 		:= {}
	
	aAdd(aOrdem, "Por Ticket")
	aAdd(aOrdem, "Por Item")
		
	oSection := TRSection():new(oReport,,,aOrdem)
	TRCell():new(oSection, "SEQUENCIA", 	cAlias, "Ticket", 		nil, 							TamSX3("ZZ1_SEQUEN")[1])
	TRCell():new(oSection, "PESO_INICIAL",	cAlias, "Peso Inicial",		PesqPict("ZZ1", "ZZ1_PESINI"), 	TamSX3("ZZ1_PESINI")[1],,,,,"RIGHT")
	TRCell():new(oSection, "PESO_FINAL",	cAlias, "Peso Final",		PesqPict("ZZ1", "ZZ1_PESFIM"), 	TamSX3("ZZ1_PESFIM")[1],,,,,"RIGHT")
	TRCell():new(oSection, "PESO_LIQUIDO",	cAlias, "Peso Líquido",		PesqPict("ZZ1", "ZZ1_PESLIQ"), 	TamSX3("ZZ1_PESLIQ")[1],,,,,"RIGHT")
	TRCell():new(oSection, "DT_PES_INI",	cAlias, "Dt. Peso Inicial",	nil, 							15)
	TRCell():new(oSection, "HR_PES_INI",	cAlias, "Hr. Peso Inicial",	nil, 							15)
	TRCell():new(oSection, "DT_PES_FIM",	cAlias, "Dt. Peso Final",	nil, 							15)
	TRCell():new(oSection, "HR_PES_FIM",	cAlias, "Hr. Peso Final",	nil, 							15)
	TRCell():new(oSection, "ITEM",			cAlias,	"Item",				nil, 							TamSX3("ZZ1_CODITE")[1])
	TRCell():new(oSection, "ARQUIVO",		cAlias,	"Arquivo TXT",		nil, 							TamSX3("ZZ1_ARQTXT")[1])
	TRCell():new(oSection, "UTILIZADO",		cAlias,	"Utilizado?",		nil, 							TamSX3("ZZ1_UTILIZ")[1]+2)
	
Return

/*/{Protheus.doc} procImpressao
	Processamento da impressão.
	@type  Static Function
	@author Diogo Mesquita
	@since 14/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function procImpressao()
	
	Local nOrder	:= oSection:getOrder()
	Local cItem		:= ""
	Local cDescItem	:= ""
	
	If nOrder == 1 // Por Ticket
		oBreak := TRBreak():New(oSection,{|| oSql:isEof()},"Total Geral",.F.)
	Else // Por Item
		oBreak := TRBreak():New(oSection,oSection:Cell("ITEM"),{|| "Total do Item " + cItem + " - " + cDescItem},.F.)
	EndIf
	TRFunction():new(oSection:cell("PESO_LIQUIDO"), Nil, "SUM", oBreak, /*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	
	cAlias := oSql:getAlias()
	oSection:cAlias := cAlias
	oReport:startPage()
	oSection:init()
	
	oReport:SetMeter(oSql:count())

	While oSql:notIsEof()
		oReport:IncMeter()

		If oSql:getValue("UTILIZADO") == "S"
			oSection:Cell("UTILIZADO"):setValue("Sim")
		Else
			oSection:Cell("UTILIZADO"):setValue("Não")
		EndIf

		oSection:printLine()

		If nOrder == 2
			cItem := oSql:getValue("ITEM")
			cDescItem := Posicione("SB1",1,xFilial("SB1")+cItem,"B1_DESC")                      
		EndIf

		oSql:skip()
	EndDo
	
	oSection:finish()
	oSql:close()
	
Return

/*/{Protheus.doc} getDadosRel
	Monta a query.
	@type  Static Function
	@author Diogo Mesquita
	@since 14/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static function getDadosRel()
	
	Local cQuery	:= ""
	Local nOrder	:= oSection:getOrder()
	
	cQuery += " SELECT " + CRLF
	cQuery += " 	ZZ1_SEQUEN SEQUENCIA, " + CRLF
	cQuery += " 	ZZ1_PESINI PESO_INICIAL, " + CRLF
	cQuery += " 	ZZ1_PESFIM PESO_FINAL, " + CRLF
	cQuery += " 	ZZ1_PESLIQ PESO_LIQUIDO, " + CRLF
	cQuery += " 	ZZ1_DTPEIN DT_PES_INI, " + CRLF
	cQuery += " 	ZZ1_HRPEIN HR_PES_INI, " + CRLF
	cQuery += " 	ZZ1_DTPEFI DT_PES_FIM, " + CRLF
	cQuery += " 	ZZ1_HRPEFI HR_PES_FIM, " + CRLF
	cQuery += " 	ZZ1_CODITE ITEM, " + CRLF
	cQuery += " 	ZZ1_ARQTXT ARQUIVO, " + CRLF
	cQuery += " 	ZZ1_UTILIZ UTILIZADO " + CRLF
	cQuery += " FROM #ZZ1.SQLNAME# " + CRLF
   	cQuery += " WHERE " + CRLF
	cQuery += " 	ZZ1_FILIAL = #ZZ1.FILIAL# AND " + CRLF
	cQuery += "		ZZ1_SEQUEN BETWEEN '"+cTicketDe+"' AND '"+cTicketAte+"' AND " + CRLF
	cQuery += "		ZZ1_DTPEIN BETWEEN '"+DtoS(dDtPeInDe)+"' AND '"+DtoS(dDtPeInAte)+"' AND " + CRLF
	cQuery += "		ZZ1_DTPEFI BETWEEN '"+DtoS(dDtPeFiDe)+"' AND '"+DtoS(dDtPeFiAte)+"' AND " + CRLF
	cQuery += "		ZZ1_CODITE BETWEEN '"+cItemDe+"' AND '"+cItemAte+"' AND " + CRLF
	
	If cJaUtilizados == "Sim"
		cQuery += "		ZZ1_UTILIZ = 'S' AND " + CRLF
	ElseIf cJaUtilizados == "Não"
		cQuery += "		ZZ1_UTILIZ = ' ' AND " + CRLF
	EndIf
	
	cQuery += " 	#ZZ1.NOTDEL# " + CRLF
	cQuery += "	ORDER BY "
	
	If nOrder == 1 // Por Sequencia
		cQuery += " SEQUENCIA "
	Else // Por Item
		cQuery += " ITEM, DT_PES_INI "
	EndIf

	oSql := IpSqlObject():newIpSqlObject()
	
	oSql:newAlias(cQuery)
	oSql:setField("DT_PES_INI", "D")
	oSql:setField("DT_PES_FIM", "D")
	
Return
