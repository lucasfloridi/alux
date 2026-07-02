//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "TOPCONN.CH"

//Variveis Estaticas
Static cTitulo := "Despesas de Viagem"
Static cTabPai := "SZM"
Static cTabFilho := "SZN"
Static aPendAnexo := {}   // Item 3: anexos selecionados no INCLUIR, gravados no commit

/*/{Protheus.doc} User Function RRDVC001
Cadastro de Despesas de Viagem
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/

User Function RRDVC001()
	Local aArea      := FWGetArea()
	Local oBrowse
	Private aRotina  := {}
	Private cFornece := ""
	Private cAprov   := ""
	Private cLojaFor := ""
	Private cNomeFor := ""

	DbSelectArea("SA2")
	DbSetOrder(11)
	If SA2->(DbSeek(xFilial("SA2") + RetCodUsr()))
		cFornece := SA2->A2_COD
		cLojaFor := SA2->A2_LOJA
		cNomeFor := SA2->A2_NREDUZ
		cAprov   := SA2->A2_XUSRAPR
	Else
		cFornece := Space(TamSX3("A2_COD")[1])
		cLojaFor := Space(TamSX3("A2_LOJA")[1])
		cNomeFor := Space(TamSX3("A2_NREDUZ")[1])
		cAprov   := Space(TamSX3("A2_XUSRAPR")[1])
	Endif

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()
	oBrowse:DisableReport()

	//Filtrando os dados
	If !(RetCodUsr() $ '000000|000328')
    	oBrowse:SetFilterDefault("Alltrim(SZM->ZM_USUARIO) = '" + RetCodUsr() + "' .OR. SZM->ZM_APROV = '" + RetCodUsr() + "' ")
	Endif

	//Adicionando as Legendas
	oBrowse:AddLegend( "ZM_STATUS = '1'", "BLUE",    	"Pendente" )
	oBrowse:AddLegend( "ZM_STATUS = '2'", "ORANGE",   	"Enviado para Aprova��o" )
	oBrowse:AddLegend( "ZM_STATUS = '3'", "GREEN",    	"Aprovado" )
	oBrowse:AddLegend( "ZM_STATUS = '4'", "RED",    	"Pago" )
	
	

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao RRDVC001
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.RRDVC001" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.RRDVC001" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.RRDVC001" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.RRDVC001" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.RRDVC001" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Enviar para Aprova��o" ACTION "U_RRDV001D" OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Aprovar" ACTION "U_RRDV001F" OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Reprovar" ACTION "U_RRDV001G" OPERATION 6 ACCESS 0	

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao RRDVC001
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/

Static Function ModelDef()
	Local oStruPai := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho)
	Local aRelation := {}
	Local oModel
	Local aGatilhos := {}
    Local nAtual
	//Local bPre := Nil
	//Local bPos := Nil
	//Local bCancel := Nil

	//Validacoes do Modelo
	//bPre := {|| U_RRDV001A() }
	//bPos := {|| U_RRDV001B }
	//bCancel := {|| U_RRDV001C }

	//Adicionando gatilhos para a SZM 
	 aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_FORNECE",;                                	//Campo Origem
        "ZM_USUARIO",;                                 	//Campo Destino
        "SA2->A2_XUSRRDV",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "001");                                      	//Sequ�ncia do gatilho
    )

	aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_LOJA",; 	                              	//Campo Origem
        "ZM_USUARIO",;                                 	//Campo Destino
        "SA2->A2_XUSRRDV",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "001");                                      	//Sequ�ncia do gatilho
    )

    aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_FORNECE",;                                	//Campo Origem
        "ZM_APROV",;                                 	//Campo Destino
        "SA2->A2_XUSRAPR",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "002");                                      	//Sequ�ncia do gatilho
    )

	aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_LOJA",; 	                              	//Campo Origem
        "ZM_APROV",;                                 	//Campo Destino
        "SA2->A2_XUSRAPR",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "002");                                      	//Sequ�ncia do gatilho
    )

	aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_FORNECE",;                                	//Campo Origem
        "ZM_NOME",;                                 	//Campo Destino
        "SA2->A2_NREDUZ",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "003");                                      	//Sequ�ncia do gatilho
    )

	aAdd(aGatilhos, FWStruTriggger( ;
        "ZM_LOJA",; 	                              	//Campo Origem
        "ZM_NOME",;                                 	//Campo Destino
        "SA2->A2_NREDUZ",;           					//Regra de Preenchimento
        .T.,;                                       	//Ir� Posicionar?
        "SA2",;                                        	//Alias de Posicionamento
        1,;                                         	//�ndice de Posicionamento
        'XFILIAL("SA2")+M->ZM_FORNECE + M->ZM_LOJA',;   //Chave de Posicionamento
        NIL,;                                      	 	//Condi��o para execu��o do gatilho
        "003");                                      	//Sequ�ncia do gatilho
    )

	For nAtual := 1 To Len(aGatilhos)
        oStruPai:AddTrigger( ;
            aGatilhos[nAtual][01],; //Campo Origem
            aGatilhos[nAtual][02],; //Campo Destino
            aGatilhos[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
            aGatilhos[nAtual][04];  //Bloco de c�digo de execu��o do gatilho
        )
    Next	

	//Adicionando gatilhos para a SZN 
	aGatilhos := {}
    aAdd(aGatilhos, FWStruTriggger( ;
        "ZN_NATUREZ",;                                //Campo Origem
        "ZN_DESCRI",;                                 //Campo Destino
        "SED->ED_DESCRIC",;           //Regra de Preenchimento
        .T.,;                                       //Ir� Posicionar?
        "SED",;                                        //Alias de Posicionamento
        1,;                                         //�ndice de Posicionamento
        'XFILIAL("SED")+M->ZN_NATUREZ',;                                        //Chave de Posicionamento
        NIL,;                                       //Condi��o para execu��o do gatilho
        "001");                                      //Sequ�ncia do gatilho
    )

	For nAtual := 1 To Len(aGatilhos)
        oStruFilho:AddTrigger( ;
            aGatilhos[nAtual][01],; //Campo Origem
            aGatilhos[nAtual][02],; //Campo Destino
            aGatilhos[nAtual][03],; //Bloco de c�digo na valida��o da execu��o do gatilho
            aGatilhos[nAtual][04];  //Bloco de c�digo de execu��o do gatilho
        )
    Next			
	
	//Inicializadores Padr�es
	oStruPai:SetProperty("ZM_FORNECE", MODEL_FIELD_INIT, {|| cFornece })
	oStruPai:SetProperty("ZM_APROV", MODEL_FIELD_INIT, {|| cAprov })
	oStruPai:SetProperty("ZM_LOJA", MODEL_FIELD_INIT, {|| cLojaFor })
	oStruPai:SetProperty("ZM_NOME", MODEL_FIELD_INIT, {|| cNomeFor })
	OStruPai:SetProperty("ZM_STATUS", MODEL_FIELD_INIT, {|| "1"})
	oStruFilho:SetProperty("ZN_NATUREZ", MODEL_FIELD_INIT, {|| "51523"})
	oStruFilho:SetProperty("ZN_DESCRI", MODEL_FIELD_INIT, {|| Posicione("SED",1,XFILIAL("SED")+"51523","ED_DESCRIC") })
	oStruFilho:SetProperty("ZN_HRDIGIT", MODEL_FIELD_INIT, {|| Time() })   // hora automatica da digitacao da linha
	
	//Cria o modelo de dados para cadastro
	aPendAnexo := {}   // Item 3: zera anexos pendentes ao (re)abrir o modelo
	oModel := MPFormModel():New("RRDVC1PE", /*bPre*/, /*bPos*/, {|oMdl| ComitRDV(oMdl)}, /*bCancel*/)
	oModel:AddFields("SZMMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("SZNDETAIL","SZMMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("SZMMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("SZNDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})
	
	//Fazendo o relacionamento
	aAdd(aRelation, {"ZN_FILIAL", "FWxFilial('SZN')"} )
	aAdd(aRelation, {"ZN_CODIGO", "ZM_CODIGO"})
	oModel:SetRelation("SZNDETAIL", aRelation, SZN->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao RRDVC001
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("RRDVC001")
	Local oStruPai := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	oStruPai:SetProperty("ZM_DTENVIO"	, MVC_VIEW_CANCHANGE, .F.)
	oStruPai:SetProperty("ZM_HRENVIO"	, MVC_VIEW_CANCHANGE, .F.)
	oStruPai:SetProperty("ZM_DTAPROV"	, MVC_VIEW_CANCHANGE, .F.)
	oStruPai:SetProperty("ZM_HRAPROV"	, MVC_VIEW_CANCHANGE, .F.)
	oStruPai:SetProperty("ZM_APROV"		, MVC_VIEW_CANCHANGE, .F.)
	oStruPai:SetProperty("ZM_LOGAPRO"	, MVC_VIEW_CANCHANGE, .F.)

	oStruFilho:SetProperty("ZN_ITEM"		, MVC_VIEW_CANCHANGE, .F.)
	oStruFilho:SetProperty("ZN_DIRETOR"		, MVC_VIEW_CANCHANGE, .F.)
	oStruFilho:SetProperty("ZN_HRDIGIT"		, MVC_VIEW_CANCHANGE, .F.)

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZM", oStruPai, "SZMMASTER")
	oView:AddGrid("VIEW_SZN",  oStruFilho,  "SZNDETAIL")

	//Botoes personalizados
	oView:addUserButton("Anexar Compr. ao Item", "MAGIC_BMP", {|| U_RRDV001H()}, /*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}, /*lShowBar*/)
	oView:addUserButton("Abrir Compr. do Item", "MAGIC_BMP", {|| U_RRDV001I()}, /*cToolTip*/, /*nShortCut*/, , /*lShowBar*/)
	If FWIsInCallSatack("U_RRDV001G")
		oView:addUserButton("REPROVAR Despesa de Viagem", "MAGIC_BMP", {|| Reprova()}, /*cToolTip*/, /*nShortCut*/, , .T./*lShowBar*/)
	Endif

	If  FWIsInCallSatack("U_RRDV001F")
		oView:addUserButton("APROVAR Despesa de Viagem", "MAGIC_BMP", {|| Aprova()}, /*cToolTip*/, /*nShortCut*/, , .T./*lShowBar*/)
	Endif
	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 20)
	oView:CreateHorizontalBox("GRID", 80)
	oView:SetOwnerView("VIEW_SZM", "CABEC")
	oView:SetOwnerView("VIEW_SZN", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_SZM", "Cabecalho - Deespesas de Viagem")
	oView:EnableTitleView("VIEW_SZN", "Grid - Itens de Despesas de Viagem")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_SZN", "ZN_ITEM")

Return oView

User Function RRDV001A()
	Local oModelPad  := FWModelActive()
	Local nOpc       := oModelPad:GetOperation()
	Local lRet       := .T.
	
	//Se for inclus�o ou exclus�o
	If (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_DELETE) .AND. oModelPad:GetValue("SZMMASTER", "ZM_STATUS") <> "1"
		FWAlertError("Apenas despesas com status 'Pendente' podem ser alteradas ou exclu�das!","N�o permitido")
		lRet := .F.	
	EndIf
Return lRet


/*/{Protheus.doc} RFAT99D
Enviar para Aprova��o
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/

User Function RRDV001D()
	Local aArea  := FWGetArea()
	Local cSemCp := ""

	If SZM->ZM_STATUS <> "1"
		FWAlertError("A Despesa deve estar com o status 'Pendente' para ser enviada para aprova��o!","N�o pendente")
		Return
	Endif

	// Comprovante obrigatorio: todo item da despesa deve ter anexo (ZN_DIRETOR)
	// para poder enviar para aprovacao.
	DbSelectArea("SZN")
	SZN->(DbSetOrder(1))
	If SZN->(DbSeek(xFilial("SZN") + SZM->ZM_CODIGO))
		While !SZN->(Eof()) .And. SZN->ZN_CODIGO == SZM->ZM_CODIGO .And. SZN->ZN_FILIAL == SZM->ZM_FILIAL
			If Empty(SZN->ZN_DIRETOR)
				cSemCp += AllTrim(SZN->ZN_ITEM) + ", "
			EndIf
			SZN->(DbSkip())
		EndDo
	EndIf
	If !Empty(cSemCp)
		FWAlertError("Anexe o comprovante de TODOS os itens antes de enviar para aprovacao." + CRLF + ;
			"Item(ns) sem comprovante: " + Left(cSemCp, Len(cSemCp) - 2), "Comprovante obrigatorio")
		FWRestArea(aArea)
		Return
	EndIf

	MailAprova()

	RecLock("SZM",.F.)
	SZM->ZM_STATUS := "2"
	SZM->ZM_DTENVIO := Date()
	SZM->ZM_HRENVIO := Time()
	MsUnLock()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} RFAT99D
Gerar Titulos Financeiros
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/
Static Function RRDV001E()

	Local aVetSE2 := {}
	Local dVencto := Date()
	Local cNumero := ""
	Local nDia    := 0
	Local nDiaCorte := 0
	Local nDiaVenc  := 0
	Private lMsErroAuto := .F.

	
	cNumero := SZN->ZN_CODIGO+SZN->ZN_ITEM
	

	aVetSE2 := {}
	aadd(aVetSE2, {"E2_FILIAL" , xFilial("SE2")       , Nil})
	aadd(aVetSE2, {"E2_NUM"    , cNumero       , Nil})
	aadd(aVetSE2, {"E2_PREFIXO", "RDV"                , Nil})
	aadd(aVetSE2, {"E2_TIPO"   , "FTF"                , Nil})
	aadd(aVetSE2, {"E2_NATUREZ", SZN->ZN_NATUREZ      , Nil})
	aadd(aVetSE2, {"E2_FORNECE", SZM->ZM_FORNECE      , Nil})
	aadd(aVetSE2, {"E2_LOJA"   , SZM->ZM_LOJA         , Nil})
	aadd(aVetSE2, {"E2_NOMFOR" , SZM->ZM_NOME         , Nil})
	aadd(aVetSE2, {"E2_EMISSAO", Date()               , Nil})
	// Vencimento (regra Alux): aprovacao ate o dia de corte (padrao 12,
	// >= 3 dias antes do dia fixo) -> vence no dia fixo (padrao 15); apos
	// o corte -> vence no ultimo dia do mes.
	// Parametrizavel via SuperGetMV com valor padrao no codigo: se o
	// parametro nao existir, usa o default (criacao nao obrigatoria).
	nDiaCorte := SuperGetMV("MV_XRDVCRT", .F., 12)   // ultimo dia p/ vencer no dia fixo
	nDiaVenc  := SuperGetMV("MV_XRDVENC", .F., 15)   // dia fixo de vencimento na quinzena
	nDia := Day(Date())
	If nDia <= nDiaCorte
		dVencto := Date() - nDia + nDiaVenc
	Else
		dVencto := MonthSum(Date() - nDia + 1, 1) - 1
	EndIf
	aadd(aVetSE2, {"E2_VENCTO" , dVencto              , Nil})
	aadd(aVetSE2, {"E2_VENCREA", DataValida(dVencto)  , Nil})
	aadd(aVetSE2, {"E2_VALOR"  , SZN->ZN_VALOR        , Nil})
	aadd(aVetSE2, {"E2_CCUSTO" , SZN->ZN_CC           , Nil})
	aadd(aVetSE2, {"E2_HIST"   , "DESPESAS DE VIAGEM" , Nil})
	aadd(aVetSE2, {"E2_MOEDA"  , 1                    , Nil})

	//Inicia o controle de transa��o
	Begin Transaction
		//Chama a rotina autom�tica
		lMsErroAuto := .F.
		MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

		//Se houve erro, mostra o erro ao usu�rio e desarma a transa��o
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
		Else
			RecLock("SE2",.F.)
			SE2->E2_DATALIB := dDatabase
			SE2->(MsUnlock())
			
			RecLock("SZN",.F.)
			SZN->ZN_RECSE2 := SE2->(RECNO())
			MsUnLock()			
		EndIf
		//Finaliza a transa��o
	End Transaction

Return
/*/{Protheus.doc} RFAT99D
Aprovar Despesa de Viagem
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/
User Function RRDV001F()

	Local aArea := FWGetArea()
	Local aEnable := {}
	Local nX

	For nx := 1 to 14
		AADD(aEnable, {.F.,NIL})
	Next 

	//aEnable[7][1] := .T. 
	//aEnable[7][2] := "APROVAR Despesa de Viagem"

	aEnable[8][1] := .T.
	aEnable[8][2] := "Fechar"
	
	If Alltrim(SZM->ZM_APROV) <> RetCodUsr()
		FWAlertError("Apenas o aprovador " + Alltrim(SZM->ZM_APROV) + " - " + Alltrim(UsrRetName(Alltrim(SZM->ZM_APROV))) +;
		" pode aprovar esta despesa de viagem! Despesa n�mero " + Alltrim(SZM->ZM_CODIGO),;
		"Aprovador " + Alltrim(RetCodUsr()) + " - " + Alltrim(UsrRetName(Alltrim(RetCodUsr()))) + " inv�lido")
		FWRestArea(aArea)
		Return
	Endif

	If SZM->ZM_STATUS <> "2"
		FWAlertError("A Despesa deve estar com o status 'Enviado para Aprova��o' para ser Aprovada!","N�o aprovado ou pago")
		FWRestArea(aArea)
		Return
	Endif

	nRet := FWExecView('Aprova��o de Despesa de Viagem', 'RRDVC001', MODEL_OPERATION_VIEW,,,,, aEnable)

	FWRestArea(aArea)

Return

Static Function Aprova()

	Local aArea := FWGetArea()

	If !FwAlertYesNo("Confirma a aprova��o desta despesa de viagem e gera��o do lan�amento financeiro?", "Confirma��o de Aprova��o")
		FWRestArea(aArea)
		Return
	EndIf
	
    DbSelectArea("SZN")
	SZN->(DbSetOrder(1))
	If !SZN->(DbSeek(xFilial("SZN") + SZM->ZM_CODIGO))
		Return
	EndIf
	Begin Transaction

		While !SZN->(Eof()) .And. SZN->ZN_CODIGO == SZM->ZM_CODIGO .and. SZN->ZN_FILIAL == SZM->ZM_FILIAL
			MSGRUN("Gerando titulos "+SZN->ZN_ITEM,"Aguarde...",{||RRDV001E()})
			SZN->(DbSkip())
		EndDo

		RecLock("SZM",.F.)
		SZM->ZM_STATUS := "3"
		SZM->ZM_DTAPROV := Date()
		SZM->ZM_HRAPROV := Time()
		MsUnLock()
	End Transaction

	fwAlertSuccess("Despesa de Viagem Aprovada com sucesso!","Aprova��o realizada")
	
	FWRestArea(aArea)

Return

User Function RRDV001G()
	Local aArea         := FWGetArea()    
	Local aEnable := {}
	Local nX

	For nx := 1 to 14
		AADD(aEnable, {.F.,NIL})
	Next 

	//aEnable[7][1] := .T. 
	//aEnable[7][2] := "REPROVAR Despesa de Viagem"

	aEnable[8][1] := .T.
	aEnable[8][2] := "Fechar"	

	/*If SZM->ZM_APROV <> RetCodUsr()
		FWAlertError("Apenas o aprovador designado pode rejeitar esta despesa de viagem!","Aprovador inv�lido")
		FWRestArea(aArea)
		Return
	Endif*/

	If SZM->ZM_STATUS <> "2"
		FWAlertError("A Despesa deve estar com o status 'Enviado para Aprova��o' para ser Reprovada!","N�o aprovado ou pago")
		FWRestArea(aArea)
		Return
	Endif

	nRet := FWExecView('Reprova��o de Despesa de Viagem', 'RRDVC001', MODEL_OPERATION_VIEW,,,,, aEnable)

	FWRestArea(aArea)

Return

Static Function Reprova()

	Local aArea         := FWGetArea()
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 154
    Local nJanLargur    := 318
    Local cJanTitulo    := 'Justificativa de Reprova��o'
    Local lDimPixels    := .T.
    Local lCentraliz    := .T.
    Local nObjLinha     := 0
    Local nObjColun     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0
	Local lContinua     := .T.

	Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt
    Private bBlocoIni   :={|| }
    //objeto0 
    Private oMulObj0
    Private cMulObj0    := ''
    //objeto1 
    Private oBtnObj1
    Private cBtnObj1    := 'Confirmar'
    Private bBtnObj1    :={|| lContinua := IIf(Empty(cMulObj0), .F., .T.), oDialogPvt:End()}

   	If !FwAlertYesNo("Confirma a reprova��o desta despesa de viagem e retorno da mesma ao status 'Pendente'?", "Confirma��o de Reprova��o")
		FWRestArea(aArea)
		Return
	EndIf

	//Cria a dialog
    oDialogPvt := TDialog():New(0, 0, nJanAltura, nJanLargur, cJanTitulo, , , , , , nCorFundo, , , lDimPixels)
     
        //objeto0 - usando a classe TMultiGet
        nObjLinha := 7
        nObjColun := 6
        nObjLargu := 145
        nObjAltur := 40
        oMulObj0  := TMultiGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , cMulObj0 := u, cMulObj0)}, oDialogPvt, nObjLargu, nObjAltur, oFontPadrao, , , , , lDimPixels, , , /*bWhen*/, , , /*lReadOnly*/, /*bValid*/, , , /*lNoBorder*/, .T.)
 
        //objeto1 - usando a classe TButton
        nObjLinha := 54
        nObjColun := 6
        nObjLargu := 75
        nObjAltur := 15
        oBtnObj1  := TButton():New(nObjLinha, nObjColun, cBtnObj1, oDialogPvt, bBtnObj1, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)
 
     
    //Ativa e exibe a janela
    oDialogPvt:Activate(, , , lCentraliz, , , bBlocoIni)

	If !lContinua
		FWAlertError("Para Rejei��o � obrigat�rio informar o motivo!","Motivo n�o informado	")
		FWRestArea(aArea)
		Return
	Endif	

	MailReprova()	

	RecLock("SZM",.F.)
	SZM->ZM_STATUS  := "1"
	SZM->ZM_DTENVIO := CTOD("  /  /    ")
	SZM->ZM_HRENVIO := " "
	SZM->ZM_LOGAPRO := cMulObj0
	MsUnLock()

	fwAlertSuccess("Despesa de Viagem Reprovada com sucesso!","Reprova��o realizada")

	FWRestArea(aArea)

Return

Static Function MailAprova()
	Local cAssunto := "Despesa de Viagem para Aprova��o"
	Local cMsg     := ""
	Local cEmail   := Alltrim( UsrRetMail(Alltrim(SZM->ZM_APROV)) )
	Local cBOF    := Chr(13) + Chr(10)

	cMsg += '<!DOCTYPE html>' + cBOF
	cMsg += '<html lang="pt-BR">' + cBOF
	cMsg += '<head>' + cBOF
	cMsg += '    <meta charset="UTF-8">' + cBOF
	cMsg += '    <title>Solicita��o de Aprova��o - Despesas de Viagem</title>' + cBOF
	cMsg += '</head>' + cBOF
	cMsg += '<body style="margin:0; padding:0; background-color:#f4f6f8; font-family:Arial, Helvetica, sans-serif; color:#333333;">' + cBOF
	cMsg += cBOF

	cMsg += '<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f6f8; padding:20px;">' + cBOF
	cMsg += '  <tr>' + cBOF
	cMsg += '    <td align="center">' + cBOF
	cMsg += cBOF

	cMsg += '      <table width="800" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border-radius:6px; padding:24px;">' + cBOF
	cMsg += '        <tr>' + cBOF
	cMsg += '          <td>' + cBOF
	cMsg += cBOF

	cMsg += '            <h2 style="margin-top:0; color:#2c3e50;">Solicita��o de Aprova��o de Despesas de Viagem</h2>' + cBOF

	cMsg += '            <p style="line-height:1.6;">' + cBOF
	cMsg += '              O usu�rio <strong>' + Alltrim( UsrFullName(Alltrim(SZM->ZM_USUARIO)) )+ '</strong> enviou uma solicita��o de aprova��o de ' + cBOF
	cMsg += '              <strong>Despesas de Viagem</strong> referente ao per�odo <strong>' + Alltrim(SZM->ZM_PERIODO) + '</strong>.' + cBOF
	cMsg += '            </p>' + cBOF

	cMsg += '            <p style="line-height:1.6;">Segue abaixo a rela��o dos itens informados:</p>' + cBOF
	cMsg += cBOF

	cMsg += '            <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse; margin-top:20px;">' + cBOF
	cMsg += '              <thead>' + cBOF
	cMsg += '                <tr>' + cBOF
	cMsg += '                  <th align="left"  style="background-color:#2c3e50; color:#ffffff; padding:10px; font-size:13px;">Item</th>' + cBOF
	cMsg += '                  <th align="left"  style="background-color:#2c3e50; color:#ffffff; padding:10px; font-size:13px;">Natureza</th>' + cBOF
	cMsg += '                  <th align="left"  style="background-color:#2c3e50; color:#ffffff; padding:10px; font-size:13px;">Descri��o da Natureza</th>' + cBOF
	cMsg += '                  <th align="left"  style="background-color:#2c3e50; color:#ffffff; padding:10px; font-size:13px;">Centro de Custo</th>' + cBOF
	cMsg += '                  <th align="right" style="background-color:#2c3e50; color:#ffffff; padding:10px; font-size:13px;">Valor (R$)</th>' + cBOF
	cMsg += '                </tr>' + cBOF
	cMsg += '              </thead>' + cBOF
	cMsg += '              <tbody>' + cBOF

	cMsg += '                <!-- Linhas de itens -->' + cBOF
	
	nTotal := 0
	DbSelectArea("SZN")
	SZN->(DbSetOrder(1))
	If SZN->(DbSeek(xFilial("SZN") + SZM->ZM_CODIGO))
		While !SZN->(Eof()) .And. SZN->ZN_CODIGO == SZM->ZM_CODIGO .and. SZN->ZN_FILIAL == SZM->ZM_FILIAL
			cMsg += '                <tr>' + cBOF
			cMsg += '                  <td style="padding:10px; border-bottom:1px solid #e0e0e0;">' + Alltrim(SZN->ZN_ITEM) + '</td>' + cBOF
			cMsg += '                  <td style="padding:10px; border-bottom:1px solid #e0e0e0;">' + Alltrim(SZN->ZN_NATUREZ) + '</td>' + cBOF
			cMsg += '                  <td style="padding:10px; border-bottom:1px solid #e0e0e0;">' + Alltrim(SZN->ZN_DESCRI) + '</td>' + cBOF
			cMsg += '                  <td style="padding:10px; border-bottom:1px solid #e0e0e0;">' + Alltrim(SZN->ZN_CC) + '</td>' + cBOF
			cMsg += '                  <td align="right" style="padding:10px; border-bottom:1px solid #e0e0e0;">' + Transform(SZN->ZN_VALOR, "@E 999,999.99") + '</td>' + cBOF
			cMsg += '                </tr>' + cBOF
			nTotal += SZN->ZN_VALOR
			SZN->(DbSkip())
		EndDo
	Endif
	
	cMsg += '                <tr>' + cBOF
	cMsg += '                  <td colspan="4" style="padding:10px; font-weight:bold; background-color:#f1f3f5;">Total</td>' + cBOF
	cMsg += '                  <td align="right" style="padding:10px; font-weight:bold; background-color:#f1f3f5; color:#27ae60;">' + Transform(nTotal,"@E 999,999.99") + '</td>' + cBOF
	cMsg += '                </tr>' + cBOF

	cMsg += '              </tbody>' + cBOF
	cMsg += '            </table>' + cBOF
	cMsg += cBOF

	cMsg += '            <table width="100%" cellpadding="0" cellspacing="0" style="margin-top:25px;">' + cBOF
	cMsg += '              <tr>' + cBOF
	cMsg += '                <td style="background-color:#fff8e1; border-left:4px solid #f1c40f; padding:15px; font-size:13px; line-height:1.6;">' + cBOF
	cMsg += '                  <strong>Aten��o:</strong><br>' + cBOF
	cMsg += '                  Para realizar a <strong>aprova��o ou rejei��o</strong> desta solicita��o, ' + cBOF
	cMsg += '                  o usu�rio respons�vel dever� acessar a rotina de <strong>Lan�amento RDV</strong> no ' + cBOF
	cMsg += '                  <strong>Totvs Protheus</strong>.' + cBOF
	cMsg += '                </td>' + cBOF
	cMsg += '              </tr>' + cBOF
	cMsg += '            </table>' + cBOF

	cMsg += '            <p style="margin-top:30px; font-size:12px; color:#777777; text-align:center;">' + cBOF
	cMsg += '              Esta � uma mensagem autom�tica. Por favor, n�o responda este e-mail.' + cBOF
	cMsg += '            </p>' + cBOF

	cMsg += '          </td>' + cBOF
	cMsg += '        </tr>' + cBOF
	cMsg += '      </table>' + cBOF

	cMsg += '    </td>' + cBOF
	cMsg += '  </tr>' + cBOF
	cMsg += '</table>' + cBOF

	cMsg += '</body>' + cBOF
	cMsg += '</html>'
	
	//Envia o e-mail
	// cEmail := "cesar@drlsys.com;lucas@fixsystem.com.br"
	u_tEnvMail(cEmail,cAssunto,cMsg)

Return

Static Function MailReprova()
	Local cAssunto := "Despesa de Viagem Reprovada"
	Local cMsg     := ""
	Local cEmail   := Alltrim( UsrRetMail(Alltrim(SZM->ZM_USUARIO)) )
	Local cBOF    := Chr(13) + Chr(10)

	cMsg := '<!DOCTYPE html>' + cBOF
	cMsg += '<html lang="pt-BR">' + cBOF
	cMsg += '<head>' + cBOF
	cMsg += '    <meta charset="UTF-8">' + cBOF
	cMsg += '    <title>Solicita��o Reprovada - Despesas de Viagem</title>' + cBOF
	cMsg += '</head>' + cBOF
	cMsg += '<body style="margin:0; padding:0; background-color:#f4f6f8; font-family:Arial, Helvetica, sans-serif; color:#333333;">' + cBOF
	cMsg += cBOF

	cMsg += '<table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f6f8; padding:20px;">' + cBOF
	cMsg += '  <tr>' + cBOF
	cMsg += '    <td align="center">' + cBOF
	cMsg += cBOF

	cMsg += '      <table width="800" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border-radius:6px; padding:24px;">' + cBOF
	cMsg += '        <tr>' + cBOF
	cMsg += '          <td>' + cBOF
	cMsg += cBOF

	cMsg += '            <h2 style="margin-top:0; color:#c0392b;">Solicita��o de Despesas de Viagem Reprovada</h2>' + cBOF

	cMsg += '            <p style="line-height:1.6;">' + cBOF
	cMsg += '              A solicita��o de n�mero <strong>' + Alltrim(SZM->ZM_CODIGO) + '</strong>, inclu�da pelo usu�rio ' + cBOF
	cMsg += '              <strong>' + Alltrim( UsrFullName(Alltrim(SZM->ZM_USUARIO)) )+ '</strong>, foi <strong>reprovada</strong> pelo usu�rio ' + cBOF
	cMsg += '              <strong>' + Alltrim( UsrFullName(Alltrim(SZM->ZM_APROV)) )+ '</strong>.' + cBOF
	cMsg += '            </p>' + cBOF

	cMsg += '            <p style="line-height:1.6;">' + cBOF
	cMsg += '              O motivo da reprova��o segue abaixo:' + cBOF
	cMsg += '            </p>' + cBOF
	cMsg += cBOF

	cMsg += '            <table width="100%" cellpadding="0" cellspacing="0" style="margin-top:10px;">' + cBOF
	cMsg += '              <tr>' + cBOF
	cMsg += '                <td style="background-color:#fdecea; border-left:4px solid #e74c3c; padding:15px; font-size:14px; line-height:1.6;">' + cBOF
	cMsg += '                  ' + Alltrim(cMulObj0) + cBOF
	cMsg += '                </td>' + cBOF
	cMsg += '              </tr>' + cBOF
	cMsg += '            </table>' + cBOF

	cMsg += '            <p style="margin-top:25px; font-size:13px; line-height:1.6;">' + cBOF
	cMsg += '              Caso necess�rio, o usu�rio poder� ajustar as informa��es e reenviar a solicita��o ' + cBOF
	cMsg += '              para nova an�lise na rotina de <strong>Lan�amento RDV</strong> do ' + cBOF
	cMsg += '              <strong>Totvs Protheus</strong>.' + cBOF
	cMsg += '            </p>' + cBOF

	cMsg += '            <p style="margin-top:30px; font-size:12px; color:#777777; text-align:center;">' + cBOF
	cMsg += '              Esta � uma mensagem autom�tica. Por favor, n�o responda este e-mail.' + cBOF
	cMsg += '            </p>' + cBOF

	cMsg += '          </td>' + cBOF
	cMsg += '        </tr>' + cBOF
	cMsg += '      </table>' + cBOF

	cMsg += '    </td>' + cBOF
	cMsg += '  </tr>' + cBOF
	cMsg += '</table>' + cBOF

	cMsg += '</body>' + cBOF
	cMsg += '</html>'


	//Envia o e-mail
	// cEmail := "cesar@drlsys.com;lucas@fixsystem.com.br"
	u_tEnvMail(cEmail,cAssunto,cMsg)

Return

/*/{Protheus.doc} RRDV001H
Banco de Conhecimento
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/
User Function RRDV001H()
	Local aArquivos := {}
	Local nIdx
	Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))                 // Diret�rio destino dos arquivos no PROTHEUS
	Local cPathBco := cDirDoc + "co01\shared\"
	Local cCodEnt
	//Local oView       := FWViewActive()
	Local oModel       := FWModelActive()
	Local oMdGrid	 := oModel:GetModel("SZNDETAIL")

	If !FWAlertYesNo("Confirma a anexa��o de arquivos ao Banco de Conhecimento para o item " + Alltrim(oMdGrid:GetValue("ZN_ITEM")) + " - " + Alltrim(oMdGrid:GetValue("ZN_DESCRDV"))+"?", "Confirma��o de Anexa��o de Arquivos")
		Return
	Endif
	
	aArquivos := SelArq()

	If Len(aArquivos) == 0
		Return
	Endif

	// Item 3: no INCLUIR a despesa ainda nao tem codigo (RDV). Guarda os anexos
	// (item + natureza) e grava no commit (ComitRDV), apos o codigo ja existir.
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		aAdd(aPendAnexo, {Alltrim(oMdGrid:GetValue("ZN_ITEM")), Alltrim(oMdGrid:GetValue("ZN_NATUREZ")), aClone(aArquivos)})
		FWAlertInfo("Documento(s) sera(ao) anexado(s) automaticamente ao SALVAR a despesa.", "Anexar comprovante")
		Return
	EndIf

	For nIdx := 1 To Len(aArquivos)
		CpyT2S( aArquivos[nIdx], cPathBco, .F., .F. )
		DbSelectArea("SZN")
		DbSetOrder(1)
		If !SZN->(DbSeek( xFilial("SZN") + oMdGrid:GetValue("ZN_CODIGO") + oMdGrid:GetValue("ZN_ITEM") + oMdGrid:GetValue("ZN_NATUREZ")))
			FWAlertError("Registro ainda n�o foi salvo. Por favor, salve o registro antes de anexar os arquivos.","Registro n�o salvo")
			Return
		EndIf
		cCodEnt := FWxFilial("SZN") + oMdGrid:GetValue("ZN_CODIGO") + oMdGrid:GetValue("ZN_ITEM") + oMdGrid:GetValue("ZN_NATUREZ")
		cArqAtu := ExtractFile(aArquivos[nIdx])
		cDesc := SubStr(cArqAtu,1,(At(".",cArqAtu) - 1))
		cExt := Alltrim(SubStr(cArqAtu,(At(".",cArqAtu))))
		cArqNovo := cDesc + "_" + Alltrim(SZN->ZN_CODIGO) + "_" + Alltrim(SZN->ZN_ITEM) + "_" + Alltrim(DTOS(Date())) + Alltrim(STRTRAN(TIME(),":","")) + cExt
		nResult := FRename( cPathBco + cArqAtu, cPathBco + cArqNovo )

		// -- Banco Conhecimento
		// --------------------- 
		cPrxObj := GETSXENUM("ACB","ACB_CODOBJ")
	
		ConfirmSX8()

		Reclock("ACB",.T.)
		Replace ACB->ACB_FILIAL with FWxFilial("ACB")
		Replace ACB->ACB_CODOBJ with cPrxObj
		Replace ACB->ACB_OBJETO with cArqNovo
		Replace ACB->ACB_DESCRI with cDesc
		ACB->(MsUnlock())

		// -- Rela��o de Objetos x Entidade
		// --------------------------------
		Reclock("AC9",.T.)
		Replace AC9->AC9_FILIAL with FWxFilial("AC9")
		Replace AC9->AC9_FILENT with FWxFilial("SZN")
		Replace AC9->AC9_ENTIDA with "SZN"
		Replace AC9->AC9_CODENT with cCodEnt
		Replace AC9->AC9_CODOBJ with ACB->ACB_CODOBJ
		//Replace AC9->AC9_XTPDOC with "1"
		AC9->(MsUnlock())

		oMdGrid:SetValue("ZN_DIRETOR", ACB->ACB_CODOBJ)		

	Next
		
Return

/*/{Protheus.doc} SelArq
Sele��o de arquivos
@author Cesar Lopes
@since 21/01/2026
@version 1.0
@type function
/*/
Static Function SelArq()
	Local aArea     := FWGetArea()
    Local cTipArq   := ""
    Local cTitulo   := ""
    Local lSalvar   := .F.
    Local cArqSel   := ""
	LocAL aArqs    := {}

	
	//Configura��es da Janela de Sele��o de Arquivos
    
	cTipArq := "Todas extens�es (*.*) | Arquivos imagem (*.png) | Arquivos imagem (*.jpg) | Arquivos PDF (*.pdf)"
    cTitulo := "Sele��o de Arquivos de Despesas de Viagem"
    cArqSel := tFileDialog(;
        cTipArq,;                  // Filtragem de tipos de arquivos que ser�o selecionados
        cTitulo,;                  // T�tulo da Janela para sele��o dos arquivos
        ,;                         // Compatibilidade
        /*cDirIni*/,;                  // Diret�rio inicial da busca de arquivos
        lSalvar,;                  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
		;
	)
        /*GETF_MULTISELECT;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
    )*/
	
	aArqs := StrTokArr(cArqSel, ";")

	FWRestArea(aArea)

Return aArqs

User Function RRDV001I()
    Local aArea    := FWGetArea()
    Local cModeDoc := GetMV("MV_MODEDOC") // 1 = File System; 2 = DataBase
	Local oModel   := FWModelActive()
	Local oMdGrid  := oModel:GetModel("SZNDETAIL")
	Local cCodObj  := Alltrim(oMdGrid:GetValue("ZN_DIRETOR"))

	If Empty(cCodObj)
		FWAlertError("Nenhum documento anexado ao item selecionado.","Documento n�o encontrado")
		FWRestArea(aArea)
		Return
	Endif	
    
    //Se veio c�digo de objeto
    If ! Empty(cCodObj)
 
        DbSelectArea("ACB")
        ACB->(DbSetOrder(1)) // ACB_FILIAL + ACB_CODOBJ
 
        //Se conseguir posicionar
        If ACB->(MsSeek(FWxFilial("ACB") + cCodObj))
 
            //Se for sistema de arquivos
            If cModeDoc == "1"
				//U_MXOpenDoc()
                lDoc := MpDocView(ACB->ACB_OBJETO)
 
            //Se for banco de dados
            ElseIf cModeDoc == "2"
                MpBinView(ACB->ACB_OBJETO, ACB->ACB_BIND)
            EndIf
        EndIf
    EndIf

    FWRestArea(aArea)
Return

/*/{Protheus.doc} ComitRDV
Commit do modelo: grava a despesa (gera o codigo do RDV) e, so depois, grava
os anexos pendentes selecionados no INCLUIR (item 3).
@author Leonardo Barboza Ribeiro Leite
@since 19/06/2026
@type function
/*/
Static Function ComitRDV(oMdl)
	Local lOk := .T.

	// Commit padrao (grava SZM/SZN e gera o codigo do RDV)...
	lOk := FWFormCommit(oMdl)

	// ...e so depois grava os anexos pendentes do INCLUIR, com o codigo ja gerado.
	If lOk .And. !Empty(aPendAnexo)
		ProcAnexoPend(oMdl)
	EndIf

Return lOk

/*/{Protheus.doc} ProcAnexoPend
Grava os anexos pendentes (Banco de Conhecimento ACB/AC9) e atualiza ZN_DIRETOR
de cada item, usando o codigo do RDV ja gerado no commit.
@author Leonardo Barboza Ribeiro Leite
@since 19/06/2026
@type function
/*/
Static Function ProcAnexoPend(oMdl)
	Local cDirDoc  := Alltrim(GetMv("MV_DIRDOC"))
	Local cPathBco := cDirDoc + "co01\shared\"
	Local cCodigo  := Alltrim(oMdl:GetValue("SZMMASTER", "ZM_CODIGO"))
	Local cChave   := ""
	Local cCodEnt  := ""
	Local cItem    := ""
	Local cNatur   := ""
	Local aArqs    := {}
	Local cArqAtu  := ""
	Local cDesc    := ""
	Local cExt     := ""
	Local cArqNovo := ""
	Local cPrxObj  := ""
	Local nI       := 0
	Local nIdx     := 0

	For nI := 1 To Len(aPendAnexo)
		cItem  := aPendAnexo[nI][1]
		cNatur := aPendAnexo[nI][2]
		aArqs  := aPendAnexo[nI][3]

		cChave := xFilial("SZN") + PadR(cCodigo, TamSX3("ZN_CODIGO")[1]) + ;
		          PadR(cItem, TamSX3("ZN_ITEM")[1]) + PadR(cNatur, TamSX3("ZN_NATUREZ")[1])

		DbSelectArea("SZN")
		DbSetOrder(1)   // ZN_FILIAL + ZN_CODIGO + ZN_ITEM + ZN_NATUREZ
		If !SZN->(DbSeek(cChave))
			Loop
		EndIf
		cCodEnt := FWxFilial("SZN") + PadR(cCodigo, TamSX3("ZN_CODIGO")[1]) + ;
		           PadR(cItem, TamSX3("ZN_ITEM")[1]) + PadR(cNatur, TamSX3("ZN_NATUREZ")[1])

		For nIdx := 1 To Len(aArqs)
			CpyT2S(aArqs[nIdx], cPathBco, .F., .F.)
			cArqAtu  := ExtractFile(aArqs[nIdx])
			cDesc    := SubStr(cArqAtu, 1, (At(".", cArqAtu) - 1))
			cExt     := Alltrim(SubStr(cArqAtu, (At(".", cArqAtu))))
			cArqNovo := cDesc + "_" + Alltrim(cCodigo) + "_" + Alltrim(cItem) + "_" + ;
			            Alltrim(DTOS(Date())) + Alltrim(STRTRAN(TIME(), ":", "")) + cExt
			FRename(cPathBco + cArqAtu, cPathBco + cArqNovo)

			cPrxObj := GETSXENUM("ACB", "ACB_CODOBJ")
			ConfirmSX8()
			Reclock("ACB", .T.)
			Replace ACB->ACB_FILIAL with FWxFilial("ACB")
			Replace ACB->ACB_CODOBJ with cPrxObj
			Replace ACB->ACB_OBJETO with cArqNovo
			Replace ACB->ACB_DESCRI with cDesc
			ACB->(MsUnlock())

			Reclock("AC9", .T.)
			Replace AC9->AC9_FILIAL with FWxFilial("AC9")
			Replace AC9->AC9_FILENT with FWxFilial("SZN")
			Replace AC9->AC9_ENTIDA with "SZN"
			Replace AC9->AC9_CODENT with cCodEnt
			Replace AC9->AC9_CODOBJ with ACB->ACB_CODOBJ
			AC9->(MsUnlock())

			// Atualiza o ZN_DIRETOR do item ja gravado
			Reclock("SZN", .F.)
			Replace SZN->ZN_DIRETOR with ACB->ACB_CODOBJ
			SZN->(MsUnlock())
		Next nIdx
	Next nI

	aPendAnexo := {}

Return
