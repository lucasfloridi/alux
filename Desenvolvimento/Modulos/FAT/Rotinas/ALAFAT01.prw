#include "Protheus.ch"
#include "TopConn.ch"

#Define CONFIRMED			.T.
#Define CANCELED			.F.

/*/{Protheus.doc} ALAFAT01
Rotina de busca de tickets com base nas movimentações internas (SD3) para preenchimento de itens no pedido de compra
@type function
@version 1.0
@author Tiago Badoco - TOTVS IP
@since 10/03/2021
/*/
User Function ALAFAT01()
    Local aArea 	    := Lj7GetArea({"SA1", "SC5", "SC6"})
    Private aParams     := {}

    If  loadParam()
		If verificaTicket()
			FWMsgRun(,{|| Processa() },"Aguarde","Importando itens...")
		Else
			Aviso("Importação Itens do Pedido de Venda", "Já existe pedido de venda emitido com o numero do ticket informado. A importação será cancelada", {"Ok"},2)
		EndIf
                        
    EndIf
    
    Lj7RestArea(aArea)
Return

Static Function Processa()
	Local cQuery		:= SD3Query()
	Local aItens		:= {} // ARRAY CONTENDO AS INFORMAÇÕES PARA LANÇAMENTOS DOS ITENS NO PEDIDO DE VENDA
	Local lAchou		:= .F.
	Local nX			:= 0
	Private nSaldoDisp	:= 0 // SALDO DISPONÍVEL DO ITEM PESQUISADO NO MOMENTO
	Private nSaldo		:= 0 // SALDO UTILIZADO ATÉ AGORA SOMANDO TODOS OS ITENS

	TCQuery cQuery New Alias (cAlias := GetNextAlias())

	DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

	If (cAlias)->(!EoF())
	
		While (cAlias)->(!EoF())
				
			cCod   := (cAlias)->D3_COD // CÓDIGO DO PRODUTO A SER IMPORTADO PARA O PEDIDO
			nQuant := (cAlias)->D3_QUANT // QUANTIDADE NECESSÁRIA DO PRODUTO (COM BASE NO TICKET)
			nCf    := (cAlias)->D3_CF
			nSaldo := 0
			lAchou := .F.

			If nCf $ "PR0/DE9"
				aadd(aItens, {cCod, nQuant, 0, "" /*D1_DOC*/, "" /*D1_SERIE*/, "" /*D1_ITEM*/, "505", Date(), ""})
			Else
				DbSelectArea("SD1")
				DbSetOrder(26)
				DbGoTop()
				If DbSeek(xFilial("SD1")+M->C5_CLIENTE+M->C5_LOJACLI+cCod)
					While SD1->(!EoF()) .And. SD1->D1_COD == cCod .And. !lAchou
						If VerificaSaldo() // BUSCAR SE PARA A NOTA POSICIONADA EXISTE SALDO DISPONÍVEL PARA PREENCHER O ITEM DO PEDIDO DE VENDA;
							If (nSaldo + nSaldoDisp) >= nQuant
								aadd(aItens, {cCod, nQuant - nSaldo, SD1->D1_VUNIT, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_TES, SD1->D1_EMISSAO, SD1->D1_IDENTB6})
								lAchou := .T.
							Else
								aadd(aItens, {cCod, nSaldoDisp, SD1->D1_VUNIT, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_TES, SD1->D1_EMISSAO, SD1->D1_IDENTB6})
								nSaldo += nSaldoDisp
							EndIf
						EndIf
						SD1->(DbSkip())
					EndDo	
				EndIf
			EndIf

			(cAlias)->(DbSkip())
		EndDo

		If verificaItens(aItens)

			For nX := 1 to Len(aItens)
				if nX > 1
					oGetDad:AddLine()
				endif

				cCod := aItens[nX][1]

				atuCampo("C6_PRODUTO",cCod,nX)
				atuCampo("C6_UM",POSICIONE("SB1", 1, xFilial("SB1")+cCod, "B1_UM"),nX)
				atuCampo("C6_LOCAL",POSICIONE("SB1", 1, xFilial("SB1")+cCod, "B1_LOCPAD"),nX)
				atuCampo("C6_DESCRI",POSICIONE("SB1", 1, xFilial("SB1")+cCod, "B1_DESC"),nX)
				atuCampo("C6_QTDVEN",aItens[nX][2],nX)
				If aItens[nX][3] > 0
					atuCampo("C6_PRCVEN",aItens[nX][3],nX)
					atuCampo("C6_PRUNIT",aItens[nX][3],nX)
				Else
					nPrc := MaTabPrVen(M->C5_TABELA,cCod,aItens[nX][2],M->C5_CLIENTE,M->C5_LOJACLI,M->C5_MOEDA,M->C5_EMISSAO)
					atuCampo("C6_PRCVEN",nPrc,nX)
					atuCampo("C6_PRUNIT",nPrc,nX)
				EndIf
				If (Val(aItens[nX][7]) > 500)
					atuCampo("C6_TES",aItens[nX][7],nX)
				Else
					atuCampo("C6_TES",  POSICIONE("SF4",1,xFilial("SF4")+aItens[nX][7], "F4_TESDV"),nX)
				EndIf
				atuCampo("C6_NFORI" ,aItens[nX][4],nX)
				atuCampo("C6_SERIORI",aItens[nX][5],nX)
				atuCampo("C6_ITEMORI",aItens[nX][6],nX)
				atuCampo("C6_IDENTB6",aItens[nX][9],nX)
				atuCampo("C6_ZZTICKE",aParams[1],nX)

				If (!Empty(aItens[nX][4]))
					atuCampo("C6_INFAD", "Nota: " + aItens[nX][4] + "/" + aItens[nX][5] + " Emissão: " + DToC(aItens[nX][8]), nX)
				EndIf

				//Atualiza totalizador
				A410LinOk(,.T.)
			Next nX

			oGetDad:LNEWLINE := .F. 
			oGetDad:oBrowse:Refresh(.T.)

			M->C5_MENNOTA := ALLTRIM(M->C5_MENNOTA) + "Documento: " + aParams[1] + SPACE(TAMSX3("C5_MENNOTA")[1])
		Else
			Aviso("Importação Itens do Pedido de Venda", "Não há saldo suficiente para ao menos um dos itens referentes ao ticket informado. A importação será cancelada", {"Ok"},2)
		EndIf
	Else
		Aviso("Importação Itens do Pedido de Venda", "Não foram encontradas movimentações com o ticket informado", {"Ok"},2)
	EndIf
Return  

/*/{Protheus.doc} verificaTicket
Função para verificar se já existe pedido de venda gerado com o ticket informado
@type function
@author Tiago TOTVS IP
@since 05/07/2021
@return logical, .T. pode seguir com o processo, .F. já existe pedido emitido com o ticket informado
/*/
Static Function verificaTicket()
	Local lRet		:= .T.
	Local cAlias	:= GetNextAlias()

	BeginSQL Alias cAlias
	SELECT
		C6_NUM
	FROM
		%Table:SC6% SC6
	WHERE
		SC6.%NotDel%
		AND C6_ZZTICKE = %exp:aParams[1]%
	EndSQL

	If (cAlias)->(!Eof())
		lRet := .F.
	EndIf
	
	(cAlias)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} verificaItens
Função para verificar se todos os itens do apontamento de produção possuem saldo para importação.
@type function
@author Tiago TOTVS IP
@since 05/07/2021
@param aItens, array, Array de itens para importação do pedido
@return logical, .T. pode seguir com o processo, .F. alguns dos itens não possuem saldo para importação
/*/
Static Function verificaItens(aItens)
	Local lRet		:= .T.
	Local nX		:= 0
	Local cAlias	:= ""
	Local cQuery	:= SD3Query()
	Local nQuant	:= 0

	TCQuery cQuery New Alias (cAlias := GetNextAlias())

	DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())


	While (cAlias)->(!EoF()) .And. lRet
		nQuant := 0
		For nX := 1 to Len(aItens)
			If aItens[nX,1] == (cAlias)->D3_COD
				nQuant += aItens[nX,2]
			EndIf
		Next nX
		//Johnny Fernandes - Totvs IP - 26/08/2021 - Chamado 16032 Redmine - Alterado verificação para o campo B1_ZZCSLDA
		If nQuant <> (cAlias)->D3_QUANT .And. POSICIONE("SB1", 1, xFilial("SB1")+D3_COD, "B1_ZZCSLDA") <> "N"
			lRet := .F.
		EndIf
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} VerificaSaldo
Essa rotina tem como função verificar se aquele item específico possui saldo disponível. Verifica se já foi utilizado em outro pedido e quanto já foi utilizado.
@type function
@author Tiago TOTVS IP
@since 11/03/2021
@return logical, lRet, Retorna .T. caso exista saldo ou .F. caso não tenha saldo
/*/
Static Function VerificaSaldo()
	Local lRet		:= .F.
	Local cQuery	:= ""
    Local cAlias	:= ""

	cQuery += "SELECT CASE WHEN COUNT(*) > 0 THEN " + cValToChar(SD1->D1_QUANT) + " - SUM(C6_QTDVEN) ELSE " + cValToChar(SD1->D1_QUANT) + " END AS SALDO " + CRLF
	
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 " + CRLF

	cQuery += "WHERE SC6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "      AND SC6.C6_FILIAL  = '" + SD1->D1_FILIAL + "'" + CRLF
	cQuery += "      AND SC6.C6_PRODUTO = '" + SD1->D1_COD + "'" + CRLF	
	cQuery += "      AND SC6.C6_NFORI   = '" + SD1->D1_DOC + "'" + CRLF	
	cQuery += "      AND SC6.C6_SERIORI = '" + SD1->D1_SERIE + "'" + CRLF	
	cQuery += "      AND SC6.C6_ITEMORI = '" + SD1->D1_ITEM + "'" + CRLF

	cQuery    := ChangeQuery(cQuery)

	memowrite("\sql\ALAFAT01_GetSaldoSC6Query.sql",cQuery)

	TCQuery cQuery New Alias (cAlias := GetNextAlias())

	DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

	If (cAlias)->(!EoF())
		If (cAlias)->SALDO > 0
			nSaldoDisp := (cAlias)->SALDO	
			lRet := .T.		
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} atuCampo
Função responsável por preencher os campos do grid de pedido de venda. Essa função verifica as validações e gatilhos.
@type function
@author Tiago TOTVS IP
@since 11/03/2021
@param cCampo, character, Nome do campo a ser atualizado
@param cVal, character, Valor a ser inserido no campo informado
@param nLinha, numeric, Numero da linha correspondente ao item atualizado
/*/
Static Function atuCampo(cCampo, cVal, nLinha) 

	Local cValid := GetSx3Cache(cCampo,"X3_VALID") 
	Local cVldUser := GetSx3Cache(cCampo,"X3_VLDUSER")

	//Johnny Fernandes - Totvs IP - 20/07/2023
	//Não remover dbSelectArea("SBP"), devido a MATA093 utilizar SaveArea1 e RestArea1, 
	//quando essa rotina é utilizada em sequancia sem sair da MATA410, na sequnda execução o Alias sa SBP está fechado.
	dbSelectArea("SBP")
	
	__READVAR := "M->"+cCampo
	M->&(cCampo) := cVal
   
	IF !EMPTY(cValid) .AND. (! &(cValid))         
		ALERT('Erro ao atualizar campo: '+cCampo)
		return .F.
	ENDIF 
				
	IF !EMPTY(cVldUser) .AND. (! &(cVldUser))         
		ALERT('Erro ao atualizar campo[2]: '+cCampo)
		return .F.
	ENDIF 

	GDFieldPut(cCampo, cVal )

	If ExistTrigger(cCampo)
		RunTrigger(2,nLinha,,,cCampo)           
	EndIf   

return .T. 

/*
	Query utilizada para montar o grid de itens
*/
Static Function SD3Query()
	Local cQuery 		:= ""

	
	cQuery := "SELECT D3_COD, D3_QUANT, D3_DOC, D3_CF " + CRLF

	cQuery += "FROM "+RetSqlName("SD3")+" SD3 " + CRLF

	cQuery += "WHERE SD3.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "      AND SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF
	cQuery += "      AND SD3.D3_DOC = '" + aParams[1] + "'" + CRLF
	cQuery += "      AND SD3.D3_CF IN ('PR0','RE1', 'RE9', 'DE9')" + CRLF
	cQuery += "      AND SD3.D3_ESTORNO <> 'S'" + CRLF

	cQuery    := ChangeQuery(cQuery)
	
	memowrite("\sql\ALAFAT01_GetSD3Query.sql",cQuery)	
	                                                                   	
Return cQuery  

/*
	Monta tela de parâmetros iniciais
*/
Static Function loadParam()
    Local aParamBox := {}   
    Local nRecord   := 0
    Local lRet      := .F.

    aAdd(aParamBox,{1,"Ticket"               ,CriaVar("D3_DOC",.F.)      ,PesqPict("SD3","D3_DOC")       ,""	,"_ZSD3"     ,"" ,070,.F.})
    
    aParams := {}
    For nRecord := 1 To Len(aParamBox)
        aAdd(aParams,aParamBox[nRecord][3])
    Next nRecord

    If  ParamBox(aParamBox,"Consulta de Tickets",@aParams,/*bOk*/,/*aButtons*/,.T./*lCentered*/,/*nPosx*/,/*nPosy*/,/*oDlgWizard*/,/* cLoad*/,/* lCanSave*/,/*lUserSave*/)
        lRet := .T.
    EndIf
    
Return(lRet)
