/*
Nome			: U_ALXFAT01() -> Nil
Classe			: NFEClass
Descrição		: Classe Função para exportar dados em XML,CSV,Texto Delimitado das notas fiscais selecionadas
Nota			: -
Autor			: José Eustáquio Ladeira Jr - FSW - Totvs RP    
Ambiente		: FATURAMENTO
Cliente			: ALFAGOMMA
Menu			: -
Data Criação	: 11/12/2014
Param. Pers 	: ZZ_ROTEXP
Campos Pers.	:  
*/

#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include "SHELL.CH"

User Function ALXFAT01()
Local aArea  		:= Lj7GetArea({"SA1","SF2","SD2","SB1","SC5","SC6"})

Public oNfeClass 		:= Nil //Criado como Public para uso Externo

	//Cria a Classe
	oNfeClass := NFSEClass():New()
	
	//Atualiza o Atributo da Classe com Variável Pública Criada
	oNfeClass:oNfeClass	:= oNfeClass 
	               
	//Apresenta a Tela
	oNfeClass:MontaTela()
	                
	//Elimina a Variável após execução
	oNfeClass := Nil 

	//Restaura Área de Trabalho
	Lj7RestArea(aArea)		
	
Return Nil

//##############################
//DEFINIÇÃO DA CLASSE
//##############################

//Definição da Classe da Tela
Class NFSEClass
	
	//Define os Atributos para a Classe
	Data oNfeClass		as Object
	Data cVersaoClass	as String
	Data cTitulo		as String
	Data cBarra			as String
	Data cRotinaExp		as String
	Data cMesRef			as String
	Data cAnoRef			as String
	Data cDataRef			as String
	
	//Define os Atributos para os Dados do Prestador (Empresa)
	Data cRazao			as String
	Data cNomeFantasia 	as String
	Data cEndereco		as String
	Data cNro			as String
	Data cComplemento	as String
	Data cBairro		as String
	Data cCEP			as String
	Data cCodMun		as String	
	Data cMun			as String
	Data cEstado		as String
	Data cCodEst		as Integer
	Data cCNPJ			as String
	Data cIE			as String
	Data cIM			as String
	Data cTelefone		as String
	Data cEmail			as String	
	
	//Define os Atributos dos Dados
	Data aDadosCab  	as Array
	Data aDadosCabIt	as Array
	Data aDados			as Array
	Data aDadosIt		as Array
	Data nRegAtual		as Integer
	Data aLayout		as Array
	Data cFiltro		as String
	Data cFiltroExp		as String
	Data lComCanceladas	as Boolean
	Data lAglutina		as Boolean
	Data lConcatena		as Boolean
	
	//Define o Atributos de Parâmetros
	Data cSerieNF		as String
	Data cNFIni			as String
	Data cNFFim			as String
	Data cCliIni		as String
	Data cCliFim		as String
	Data dDataIni		as String
	Data dDataFim		as String
	Data cVersao		as String
	Data cTipoArq		as String
	Data cArquivo		as String
	Data cPastaDest		as String

	//Define os Métodos
	Method New() Constructor				//Instancia a Classe
		Method LoadEmp()					//Método para Carga dos Dados da Empresa
		Method MontaTela()					//Executa a montagem da tela com Browse e Menu para acionar outros métodos da classe
			Method LoadPerg()				//Método para Carregar as Perguntas para Execução da Tela		
			Method Legenda()				//Método para apresentar a legenda da tela
			Method Visualiz()				//Método para Visualizar a NF Posicionada
		Method Exportar()					//Método para exportar o XML da NF
			Method LoadPergExp()			//Método para Carregar as Perguntas para a Exportação dos Dados
			Method LoadData()				//Método para Carregar os Dados a serem Exportados
			Method MarkExp()				//Marca a NF como Exportada
EndClass
           
//##############################
//DEFINIÇÃO DOS MÉTODOS
//##############################

Method New() Class NFSEClass

	//Instancia Atributos da Classe
	::cTitulo		:= "NF-e"
	::cVersaoClass	:= "V1.00"
		
	//::cBarra		:=	IIf(IsSrvUnix(), "/", "\")
	::cBarra		:=	Iif(AllTrim(GetRmtInfo()[02]) $ "Linux", "/", "\") //Verifica se o Ambiente Local é Windows ou Linux	
	
	//Define o Período de Referência
	::cMesRef		:= StrZero(Month(DDATABASE),02)
	::cAnoRef		:= StrZero(Year(DDATABASE),04)
	::cDataRef		:= DtoS(DDATABASE)
	::cDataRef		:= Right(::cDataRef,2) + SubStr(::cDataRef,5,2) + Left(::cDataRef,4)
		
	//Inicializa Atributos de Dados
	::aDados		:= {}
	::aDadosIt		:= {}
	::aDadosCab		:= {}
	::aDadosCabIt	:= {}	
	::nRegAtual		:= 1
	::cFiltro		:= ""
	::cFiltroExp	:= ""
	::lComCanceladas := .F.
	
	//Inicializa Atributos de Parâmetros
	::cTipoArq		:= ""
	::cArquivo		:= ""
	::cPastaDest	:= ""
	
	//Carrega os Dados da Empresa como Atributos da Classe
	::LoadEmp()
	
Return Self

Method LoadEmp() Class NFSEClass
	
	//Define o Código, Estado, e Nome do Município Atual e a Rotina a ser utilizada
	dbSelectArea("SM0")
	::cRazao			:= Alltrim(SM0->M0_NOMECOM)
	::cNomeFantasia		:= Alltrim(SM0->M0_NOME)
	::cEndereco			:= FisGetEnd(SM0->M0_ENDENT)[01]
	::cNro				:= FisGetEnd(SM0->M0_ENDENT)[02]
	::cComplemento		:= Alltrim(SM0->M0_COMPENT)
	::cBairro			:= Alltrim(SM0->M0_BAIRENT)
	::cCEP				:= Alltrim(SM0->M0_CEPENT)
	::cCodMun			:= SubStr(Alltrim(SM0->M0_CODMUN),3) //Somente o Código do Município sem o Código do Estado
	::cMun 				:= Alltrim(SM0->M0_CIDENT)
	::cEstado			:= Alltrim(SM0->M0_ESTENT)
	//Define o Código IBGE do Estado
	::cCodEst			:= StrZero(Val(Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"AA"+::cEstado,"X5_DESCRI"))),02)
	::cCNPJ				:= Alltrim(SM0->M0_CGC)
	::cIE				:= Alltrim(SM0->M0_INSC)
	::cIM				:= Alltrim(SM0->M0_INSCM)
	::cTelefone			:= Alltrim(SM0->M0_TEL)
	::cEmail			:= Lower(Alltrim(GetMv("MV_RELFROM")))
	::lConcatena		:= AllTrim(GetNewPar("MV_ITEMAGL","N"))
	::lConcatena		:= Iif(::lConcatena=="S",.T.,.F.) 

	::cRotinaExp		:= GetMv("ZZ_ROTEXP")
	
Return Nil


//Método para Montagem da Tela            
Method MontaTela() Class NFSEClass
Local cAlias		:= "SF2"
Local aCores	   	:= {}
Local aIndices	:= {}

Private cCadastro := ::cTitulo
Private aRotina 	:= {}
Private bVisual		:= {|| ::Visualiz() 	}
Private bExport		:= {|| ::Exportar() 	}
Private bLegenda	:= {|| ::Legenda()  	}
                                    	
	//Carrega o Grupo de Perguntas da Rotina
	If ::LoadPerg()
	    
		//Define os Itens do Menu
		aAdd( aRotina , { "Pesquisar" 		, "AxPesqui"			, 0 , 1 , 0 , .F. } )
		aAdd( aRotina , { "Visualizar"		, "Eval(bVisual)"		, 0 , 2 , 0 , .F. } )
		aAdd( aRotina , { "Exportar"		, "Eval(bExport)"		, 0 , 3 , 0 , .F. } )
		aAdd( aRotina , { "Legenda"			, "Eval(bLegenda)"	, 0 , 4 , 0 , .F. } )
		
		//Define os Critérios para a Legenda
		aAdd(aCores,{" F2_ZZEMB == ' ' "  								,"BR_VERMELHO"	}) // AE Não Gerado
		aAdd(aCores,{" F2_ZZEMB == 'S' "  								,"BR_VERDE"	 	}) // AE Gerado
		             
		//Seleciiona a Tabela e Posiciona
		DbSelectArea(cAlias)
		(cAlias)->(DbSetOrder(1))
		(cAlias)->(DbGotop())
		
		//Define os Filtros a serem aplicados no Browse
		If !Empty(::cFiltro)
			FilBrowse(cAlias,@aIndices,::cFiltro ) //Prepara um filtro a ser utilizado antes de chamar a função mbrowse
		Endif
			
		//Apresenta o Browse
		MBrowse(6,1,22,75,cAlias,,,,,2,aCores,,,,,.F.,.F.,.F.,,,)	
		
		//Se o Filtro tiver sido aplicado limpa o filtro ao Sair da Rotina
		If !Empty(::cFiltro)
			EndFilBrw(cAlias,aIndices)
		Endif
	
	Endif
				
Return Nil

//Apresenta a Legenda de Cores
Method Legenda() Class NFSEClass
Local cTitLeg	 := "Legenda"
Local aLegenda   := {}

	aAdd(aLegenda,{"BR_VERMELHO" ,"AE Não Gerado"  })
	aAdd(aLegenda,{"BR_VERDE" 	 ,"AE Gerado"  	 })
	
	BrwLegenda(::cTitulo,cTitLeg,aLegenda)
Return .T.
          
//Método para Visualizar a Nota Fiscal
Method Visualiz() Class NFSEClass

	Mc090Visual("SF2",SF2->(RecNo()),1)

Return Nil

//Método para Carregar os Dados a serem considerados na Exportação dos Dados
Method LoadData() Class NFSEClass
Local lRet			:= .T.
Local cSQL			:= ""
Local cAlias		:= ""
Local cAlias2		:= ""
Local cAlias3		:= ""
Local nCont			:= 0
Local aTemp			:= {}
Local nCont			:= 0
Local aItens 		:= {}
Local cCodProd		:= ""
Local cDescProd		:= ""
Local cAux			:= ""
Local nReg			:= 0
Local nRegIt		:= 0
	
	//Inicializa Variáveis
	::aDados		:= {}
	::aDadosCab		:= {}
	::aDadosCabIt	:= {}
	nReg			:= 0
	nRegIt			:= 0
	
	//--------------------------------------------------------------------
	//Carrega o Cabeçalho dos Dados
	//--------------------------------------------------------------------	
	aTemp	:= 		{		{"Série NF","F2_SERIE"} ,;
							{"NF","F2_DOC"} ,;
							{"Emissao","F2_EMISSAO"} ,;
							{"Vlr Brut","F2_VALBRUT"} ,;
							{"Vlr Icms","F2_VALICM"} ,;
							{"Vlr Ipi","F2_VALIPI"} ,;
							{"Frete","F2_FRETE"} ,;							
							{"Seguro","F2_SEGURO"} ,;
							{"Despesa","F2_DESPESA"} ,;
							{"Desconto","F2_DESCONT"} ,;
							{"Base Icms","F2_BASEICM"} ,;
							{"Cliente","F2_CLIENTE"} ,;
							{"Loja","F2_LOJA"} ,;
							{"CNPJ","A1_CGC"} ,;
							{"Nome","A1_NOME"} ,;
							{"Id Cli","A1_ZZIDCLI"} ,;
							{"Itens da NF","ITENS"}}
							
	
	//Monta o Array com as Características do aDadosCab para uso com as Funções GdFieldGet
	::aDadosCab := Array(Len(aTemp))
	For nCont:=1 to Len(::aDadosCab)
		::aDadosCab[nCont] := Array(12) //Atributos dos Campos
		aFill(::aDadosCab[nCont],"") 	  //Inicializa Atributos
		//Define Alguns Atributos
		::aDadosCab[nCont,01] := aTemp[nCont,01]	//Título do Campo
		::aDadosCab[nCont,02] := aTemp[nCont,02] 	//Nome do Campo
	Next nCont
	
	//--------------------------------------------------------------------
	//Carrega o Cabeçalho dos Dados dos Itens dentro do Array de Dados
	//--------------------------------------------------------------------	
	aTemp	:= 		{		{"Item","D2_ITEM"} ,;
							{"Cod. Prod.","D2_COD"} ,;
							{"Quant","D2_QUANT"} ,;
							{"Uni.Med.","D2_UM"} ,;
							{"NCM","B1_POSIPI"} ,;
							{"Alq Ipi","D2_IPI"} ,;
							{"Vlr Unit","D2_PRCVEN"} ,;
							{"Vlr Desconto","D2_DESCON"} ,;								
							{"Per Desconto","D2_DESC"} ,;
							{"CFOP","D2_CF"} ,;
							{"Alq Icm","D2_PICM"},;								
							{"Base Icm","D2_BASEICM"},;
							{"Vlr Icm","D2_VALICM"},;
							{"Vlr Ipi","D2_VALIPI"},;
							{"CST","D2_CLASFIS"},;
							{"Peso","B1_PESO"},;
							{"Cod Pro Cli","B1_ZZCODCL"},;
							{"Nro Ped","D2_PEDIDO"},;
							{"Ite Ped","D2_ITEMPV"},;
							{"Vlr Total","D2_TOTAL"},;
							{"TES","D2_TES"} }
							
	
	//Monta o Array com as Características do aDadosCab para uso com as Funções GdFieldGet
	::aDadosCabIt := Array(Len(aTemp))
	For nCont:=1 to Len(::aDadosCabIt)
		::aDadosCabIt[nCont] := Array(12) //Atributos dos Campos
		aFill(::aDadosCabIt[nCont],"") 	  //Inicializa Atributos
		//Define Alguns Atributos
		::aDadosCabIt[nCont,01] := aTemp[nCont,01]	//Título do Campo
		::aDadosCabIt[nCont,02] := aTemp[nCont,02] 	//Nome do Campo
	Next nCont		

	
	//Monta a Consulta para Obtenção dos Dados das NFs
	//Obtém as Notas Fiscais de Saída	
	cSQL := " SELECT SF2.F2_FILIAL, "
	cSQL += " SF2.F2_SERIE, SF2.F2_DOC, SF2.F2_EMISSAO, SF2.F2_VALBRUT, SF2.F2_VALICM, SF2.F2_VALIPI, " + CRLF
	cSQL += " SF2.F2_FRETE, SF2.F2_SEGURO, SF2.F2_DESPESA, SF2.F2_DESCONT, SF2.F2_BASEICM, SF2.F2_CLIENTE, " + CRLF
	cSQL += " SF2.F2_LOJA, SA1.A1_CGC, SA1.A1_ZZIDCLI, SA1.A1_NOME " + CRLF 
	cSQL += " FROM " + RetSqlName("SF2") + " SF2 "
 	cSQL += 	" INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SF2.F2_CLIENTE=SA1.A1_COD AND SF2.F2_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_=' ' " + CRLF
	cSQL += " WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_=' ' "
	//cSQL += " AND SF2.F2_TIPO NOT IN ('B','D') " + CRLF
	If !Empty(::cFiltroExp)
		cSQL += " AND " + ::cFiltroExp
	Endif
	cSQL += " ORDER BY SF2.F2_SERIE, SF2.F2_DOC, SF2.F2_EMISSAO " + CRLF
		
	//Exporta a Consulta
	MemoWrite("NFSEClassa.sql",cSQL)	

	//Normaliza a Consulta
	cSQL := ChangeQuery(cSQL)
	                                               
	//Abre a Consulta
	TcQuery cSQL New Alias (cAlias:=GetNextAlias())
	
	//Transforma Campos da Consulta
	aEval( SF2->(dbStruct()) , { |Registro| Iif( Registro[2] <> "C", TcSetField( cAlias , Registro[1] , Registro[2] , Registro[3] , Registro[4] ) , Nil ) } )
	aEval( SA1->(dbStruct()) , { |Registro| Iif( Registro[2] <> "C", TcSetField( cAlias , Registro[1] , Registro[2] , Registro[3] , Registro[4] ) , Nil ) } )
	
	//Seleciona a Consulta
	dbSelectArea(cAlias)
	Count to nCont
	(cAlias)->(dbGoTop())
	
	If (cAlias)->(!EOF()) //Se Houver Dados
	
		While (cAlias)->(!EOF())
		
			cSQL := " SELECT " + CRLF
			cSQL += " SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_UM, SB1.B1_POSIPI, SD2.D2_IPI, SD2.D2_PRCVEN, " + CRLF
			cSQL += " SD2.D2_DESCON, SD2.D2_DESC, SD2.D2_CF, SD2.D2_PICM, SD2.D2_BASEICM, SD2.D2_VALICM, " + CRLF
			cSQL += " SD2.D2_VALIPI, SD2.D2_CLASFIS, SB1.B1_PESO, SD2.D2_TOTAL, SD2.D2_PEDIDO, SD2.D2_ITEMPV, SD2.D2_TES " + CRLF
			cSQL += " FROM " + RetSqlName("SD2") + " SD2 " + CRLF
			cSQL += 	" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SD2.D2_COD=SB1.B1_COD AND SB1.D_E_L_E_T_=' ' AND SB1.B1_FILIAL='"+xFilial("SB1")+"' " + CRLF
			cSQL += " WHERE SD2.D_E_L_E_T_=' ' " + CRLF
			cSQL += " AND SD2.D2_SERIE = '"  + (cAlias)->F2_SERIE 		+ "' " + CRLF
			cSQL += " AND SD2.D2_DOC = '" 	 + (cAlias)->F2_DOC 		+ "' " + CRLF
			cSQL += " AND SD2.D2_FILIAL = '" + (cAlias)->F2_FILIAL 		+ "' " + CRLF
			cSQL += " ORDER BY " + CRLF
			cSQL += " SD2.D2_ITEM " + CRLF
			
			//Exporta a Consulta
			MemoWrite("NFSEClassb.sql",cSQL)
			                    
			//Normaliza a Consulta
			cSQL := ChangeQuery(cSQL)
			                                                
			//Abre a Consulta
			TcQuery cSQL New Alias (cAlias2:=GetNextAlias())
			
			//Transforma os Campos da Consulta
			aEval( SD2->(dbStruct()) , { |Registro| Iif( Registro[2] <> "C", TcSetField( cAlias2 , Registro[1] , Registro[2] , Registro[3] , Registro[4] ) , Nil ) } )
			aEval( SB1->(dbStruct()) , { |Registro| Iif( Registro[2] <> "C", TcSetField( cAlias2 , Registro[1] , Registro[2] , Registro[3] , Registro[4] ) , Nil ) } )
			
			//Seleciona a Consulta
			dbSelectArea(cAlias2)
			(cAlias2)->(dbGoTop())   
			
			//Percorre os Dados dos Itens
			aItens 	:= {}
			nRegIt		:= 0
			While (cAlias2)->(!EOF())
			
				//Define o Item Atual
				++nRegIt
				
				//Carrega os Dados dos Itens
				aAdd( aItens , {	(cAlias2)->D2_ITEM,;	//Item
									(cAlias2)->D2_COD,;		//Cod.Produto
									(cAlias2)->D2_QUANT,;	//Quantidade
									(cAlias2)->D2_UM,;		//Unid.Med.
									(cAlias2)->B1_POSIPI,;	//NCM
									(cAlias2)->D2_IPI,;		//Aliq.Ipi
									(cAlias2)->D2_PRCVEN,;	//Vlr Unit
									(cAlias2)->D2_DESCON,;	//Vlr Desconto
									(cAlias2)->D2_DESC,;	//Per Desconto
									(cAlias2)->D2_CF,;		//CFOP
									(cAlias2)->D2_PICM,;	//Aliq.Icms
									(cAlias2)->D2_BASEICM,;	//Base Icms
									(cAlias2)->D2_VALICM,;	//Vlr Icms
									(cAlias2)->D2_VALIPI,;	//Vlr Ipi
									(cAlias2)->D2_CLASFIS,;	//CST
									(cAlias2)->B1_PESO,;	//Peso Liquido
									"",;	//Cod Prod Cli
									(cAlias2)->D2_PEDIDO,;	//Nro Pedido
									(cAlias2)->D2_ITEMPV,;	//Ite Pedido
									(cAlias2)->D2_TOTAL,; 	//Vlr Total
									(cAlias2)->D2_TES })	//TES
				//Próximo Item
				(cAlias2)->(dbSkip())
			EndDo
			(cAlias2)->(dbCloseArea()) //Fecha a Consulta dos Itens
			
			 ++nReg
		        
			//Carrega os dados para a Memória
			aAdd( ::aDados ,{ 	(cAlias)->F2_SERIE 		,;	//Série
								(cAlias)->F2_DOC 		,;	//NF
								(cAlias)->F2_EMISSAO	,;	//Emissão
								(cAlias)->F2_VALBRUT 	,;	//Vlr Bruto
								(cAlias)->F2_VALICM 	,;	//Vlr Icm
								(cAlias)->F2_VALIPI 	,;	//Vlr Ipi
								(cAlias)->F2_FRETE 		,;	//Vlr Frete
								(cAlias)->F2_SEGURO 	,;	//Vlr Seguro
								(cAlias)->F2_DESPESA 	,;	//Vlr Despesa
								(cAlias)->F2_DESCONT 	,;	//Vlr Desconto
								(cAlias)->F2_BASEICM 	,;	//Base Icms
								(cAlias)->F2_CLIENTE	,;	//Cod Cliente
								(cAlias)->F2_LOJA 		,;	//Loja Cliente
								(cAlias)->A1_CGC 		,;	//CGC
								(cAlias)->A1_NOME 		,;	//Nome
								(cAlias)->A1_ZZIDCLI 	,;	//Identificação Cliente
								aItens ,;					//Itens da NF
								.F. } )						//Flag de Exclusão
								
			//Próximo Registro
			(cAlias)->(dbSkip())
		EndDo
		lRet := .T.
	Else //Se não houver dados
		lRet := .F.
	Endif

	//Fecha a Consulta
	(cAlias)->(dbCloseArea())
	
Return (lRet)

          
//Método para Exportar a Nota Fiscal no Layout Desejado
Method Exportar() Class NFSEClass
Local aRet			:= {}
Local aDadosRet	:= {}
Local cLayout		:= ""
Local aLayout		:= {}
Local aLayCab		:= {}
Local nCont		:= 0	            
	
	//Carrega o Filtro das NFS-e a serem consideradas		
	If ::LoadPergExp()
	
		//Carrega os Dados
		If ::LoadData()
			
			//Verifica se Existe a Rotina do Munícípio
			If !Empty(::cRotinaExp) .And. ExistBlock(::cRotinaExp)
			
				//############################################################################################
				//Executa a Rotina Personalizada como Ponto de Entrada de Acordo com o Munícípio
				//############################################################################################		
				/*
				Tipos de Retornos Esperados:
				aRet[01] => Tipo do arquivo (1 = Delimitado (CSV),2 = Largura Fixa, 3 = XML)
				aRet[02] = Array com os dados a ser gerado (Vetor com 1 MB por Linha)
				aRet[03] = Nome do arquivo (opcional)
				aRet[04] = Extensão do arquivo (opcional)		
				*/
				aRet := ExecBlock(::cRotinaExp,.F.,.F.,{::oNfeClass})
				
				//Se Retornar Dados
				If Len(aRet) > 0 .And. Len(aRet[02]) > 0 //Conteúdo retornado diferente de vazio 
				
					//Define o Tipo de Arquivo a Ser Gerado pelo Código de Município da Filial Corrente
					//1=Delimitado (CSV), 2=Largura Fixa,3=XML
					::cTipoArq := aRet[01]
					
					//Define o Arquivo se o mesmo não tiver sido definido na Rotina
					If !Empty(aRet[03]) .And. !Empty(aRet[04])
						::cArquivo := ::cPastaDest + aRet[03] + "." + aRet[04]
					Else				
						Do Case 
							Case ::cTipoArq == 1 //Delimitado (CSV)
								::cArquivo := ::cPastaDest + "AE-" + alltrim(mv_par02) + IIF(mv_par02<>mv_par03,"_"+alltrim(mv_par03),"") + ".csv"
							Case ::cTipoArq == 2 //Largura Fixa
								//::cArquivo := ::cPastaDest + "AE-" + alltrim(mv_par02) + IIF(mv_par02<>mv_par03,"_"+alltrim(mv_par03),"") + ".txt"
								::cArquivo := ::cPastaDest + "AEM" + alltrim(substr(mv_par02, 4, 6)) + IIF(mv_par02<>mv_par03,"_"+alltrim(mv_par03),"") + ".txt"
							Case ::cTipoArq == 3 //XML
								::cArquivo := ::cPastaDest + "AE-" + alltrim(mv_par02) + IIF(mv_par02<>mv_par03,"_"+alltrim(mv_par03),"") + ".xml"
						EndCase
					Endif
					
					//Marca as Nfs Exportadas
					//Percorre as NFS-e
					For nCont:=1 to Len(::aDados)					
						//Define o Registro Atual
						::nRegAtual := nCont
					
						//Marca a NF como Exportada	  
						::MarkExp()						
					Next nCont //Próxima NF				
					
					//Grava os Dados no Arquivo Informado considerando o Conteúdo retornado como um Vetor
					aDadosRet := aRet[02]
					MemoWrite2(::cArquivo,aDadosRet)
					MsgInfo("Notas Fiscais Selecionadas exportadas para: " + ::cArquivo )
					
				Endif
			
			Else //Se não encontrado Rotina para o Munícipio
				
				MsgStop("Atenção! Não foi encontrado a rotina '" + AllTrim(::cRotinaExp) + "' no parâmetro, portanto, as AE's não podem ser geradas.","TOTVS IP")
				
			Endif		
		
		Else //Dados não Carregados - Por não haver dados ou por cancelamento do grupo de perguntas
		
			MsgStop("Atenção! Não foram localizados dados para serem exportados, utilizando os critérios informados.","TOTVS IP")
			
		Endif

	Endif
	
Return Nil
       
//Método para Marcar a NF como Exportada
Method MarkExp() Class NFSEClass
Local cNF		:= GdFieldGet("F2_DOC",::nRegAtual,.F.,::aDadosCab,::aDados)
Local cSerie	:= GdFieldGet("F2_SERIE",::nRegAtual,.F.,::aDadosCab,::aDados)
Local cCliente	:= GdFieldGet("F2_CLIENTE",::nRegAtual,.F.,::aDadosCab,::aDados)
Local cLoja	 	:= GdFieldGet("F2_LOJA",::nRegAtual,.F.,::aDadosCab,::aDados)

	//Posisciona no Cab. de NF de Saída	     
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(dbSeek(xFilial("SF2")+cNF+cSerie+cCliente+cLoja)) //Se encontrado
		If SF2->(MsrLock())
		
			SF2->F2_ZZEMB := "S" //Marca a NF como Exportada
			
			SF2->(MsUnLock()) //Salva as Alterações
		Endif
	Endif
Return Nil


//#############################################
//MÉTODOS AUXILIARES
//#############################################

//Função para Carregar as Perguntas Iniciais para Montagem da Tela - via ParamBox
Method LoadPerg() Class NFSEClass
Local lRet				:= .F.
Local cGrupoPerg		:= "NFSEClass"
Local cTituloPerg		:= "Filtros NF-e"
Local aComboFil		:= {"1=Sem Filtro","2=Não Geradas","3=Geradas"}
Local aRet 			:= {}
Local aParamBox		:= {}

Private cCadastro := ::cTitulo
	
	/*
	OPÇÕES PARAMBOX:
	
	1 - MsGet
	[2] : Descrição
	[3] : String contendo o inicializador do campo
	[4] : String contendo a Picture do campo
	[5] : String contendo a validação
	[6] : Consulta F3
	[7] : String contendo a validação When
	[8] : Tamanho do MsGet
	[9] : Flag .T./.F. Parâmetro Obrigatório ?
	
	2 - Combo
	[2] : Descrição
	[3] : Numérico contendo a opção inicial do combo
	[4] : Array contendo as opções do Combo
	[5] : Tamanho do Combo
	[6] : Validação
	[7] : Flag .T./.F. Parâmetro Obrigatório ?	
	*/

	//Monta as Perguntas
	aAdd(aParamBox,{1,"Série da NF"		, Space(3),"@!","",,""	, 50,.T.})  // MV_PAR01
	aAdd(aParamBox,{2,"Filtra"			,"2",aComboFil,50,""			,.T.}) 	// MV_PAR02
	aAdd(aParamBox,{1,"Cliente"			, Space(6),"@!","","SA1",""	, 50,.T.})  // MV_PAR03

	//Carrega os Parâmetros Gravados em Arquivo para a Memória
	LoadParBox(cGrupoPerg)
	
	//Verifica se irá apresentar o Grupo de Perguntas na Inicialização da Rotina
	lRet := ParamBox(aParamBox,cTituloPerg,@aRet,,,,,,,cGrupoPerg,.T.,.T.) //Carrega o Assistente
	                                 
	//Define o Filtro para o Browse da Rotina - ADVPL
	If lRet
		If MV_PAR02 == "1"
			//Sem Filtro - Nada Faz
		Elseif MV_PAR02 == "2"
			::cFiltro := " SF2->F2_ZZEMB == ' ' "  //Não Exportadas
		Elseif MV_PAR02 == "3"	
			::cFiltro := " SF2->F2_ZZEMB == 'S' " //Exportadas
		Endif
		
		If !Empty(MV_PAR01)
			If !Empty(::cFiltro)
				::cFiltro += " .AND. "
			Endif
			::cFiltro += " SF2->F2_SERIE == '" + MV_PAR01 + "' "
		Endif

		If !Empty(MV_PAR03)
			If !Empty(::cFiltro)
				::cFiltro += " .AND. "
			Endif
			::cFiltro += " SF2->F2_CLIENTE == '" + MV_PAR03 + "' "
		Endif

	Endif
	
Return (lRet)


//Método para Carregar as Perguntas para a Exportação dos Dados - via ParamBox
Method LoadPergExp() Class NFSEClass
Local lRet			:= .F.
Local cGrupoPerg	:= "NFSEClassExp"
Local cTituloPerg	:= "Filtros para Exportação"
Local aRet 		:= {}
Local aParamBox	:= {}
Local nTamSerie	:= 0
Local nTamDoc 	:= 0

Local cParNfeRem 	:= "NFSEClassExp"  
Local aParam   		:= {}
Local cPathLogo 	:= "\profile\"  
Local cArqParam 	:= cPathLogo+RetCodUsr()+"_"+ cParNfeRem+".prb"    


Private cCadastro := ::cTitulo


	If File(cArqParam)
		FERASE( cArqParam)
	EndIf

	dbSelectArea("SF2")
	nTamSerie	:= Len(SF2->F2_SERIE)
	nTamDoc 	:= Len(SF2->F2_DOC)

	//Monta as Perguntas
	aAdd(aParamBox,{1,"Série da NF"		, SF2->F2_SERIE,"@!","","",""			, 50,.T.}) // MV_PAR01
	aAdd(aParamBox,{1,"NF. Inicial"		, SF2->F2_DOC,"@!","","",""	, 50,.F.})  	// MV_PAR02
	aAdd(aParamBox,{1,"NF. Final"  		, SF2->F2_DOC,"@!","","",""	, 50,.T.})  	// MV_PAR03
	aAdd(aParamBox,{1,"Cliente Inicial" , SF2->F2_CLIENTE,"@!","","SA1",".F."		, 50,.F.})  	// MV_PAR04
	aAdd(aParamBox,{1,"Cliente Final"	, SF2->F2_CLIENTE,"@!","","SA1",".F."		, 50,.T.})  	// MV_PAR05
	aAdd(aParamBox,{1,"Data Inicial"	, CtoD("01/01/2000"),"","","",""	, 50,.F.})  		// MV_PAR06
	aAdd(aParamBox,{1,"Data Final"		, ddatabase,"","","",""	, 50,.T.})  		// MV_PAR07		
	aAdd(aParamBox,{6,"Caminho do Arquivo"	,SubStr("C:"+::cBarra+Space(100),1,100),"@!",".T.",".T.",100,.T.,"","",GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY}) // MV_PAR08
	
	//Carrega os Parâmetros Gravados em Arquivo para a Memória
	LoadParBox(cGrupoPerg)
	
	//Verifica se irá apresentar o Grupo de Perguntas na Inicialização da Rotina
	lRet := ParamBox(aParamBox,cTituloPerg,@aRet,,,,,,,cGrupoPerg,.T.,.T.) //Carrega o Assistente
	
	//Ajusta Propriedades do Objeto conforme os Parâmetros
	If lRet //Se Confirmado	
	
		//Carrega os Dados da Empresa como Atributos da Classe
		::LoadEmp()
	
		//Atualiza Atributos conforme as Perguntas
		::cSerieNF			:= MV_PAR01
		::cNFIni			:= MV_PAR02
		::cNFFim			:= MV_PAR03
		::cCliIni			:= MV_PAR04
		::cCliFim			:= MV_PAR05
		::dDataIni			:= MV_PAR06
		::dDataFim			:= MV_PAR07
		
		//Define o Filtro para a execução da Exportação da Rotina - SQL
		::cFiltroExp := " F2_SERIE = '" + ::cSerieNF + "' " + CRLF
		::cFiltroExp += " AND F2_DOC BETWEEN '" + ::cNFIni 	+ "' AND '" + ::cNFFim + "' " + CRLF //NF - Doc no Protheus
		::cFiltroExp += " AND F2_CLIENTE BETWEEN '" + ::cCliIni  + "' AND '" + ::cCliFim + "' " + CRLF //CLIENTE
		::cFiltroExp += " AND F2_EMISSAO BETWEEN '" + DTOS(::dDataIni) + "' AND '" + DTOS(::dDataFim) + "' " + CRLF	
		
		//Define o Caminho da Exportação
		::cPastaDest 	:= AllTrim(MV_PAR08)
		If Left(::cPastaDest,1) == ::cBarra
			If Len(::cPastaDest) > 1
				::cPastaDest := SubStr(::cPastaDest,2)
			Else 
				::cPastaDest := ""
			Endif
		Endif	
		
		//Define o Nome do Arquivo a ser Gerado
		::cPastaDest += Iif(Right(::cPastaDest,1)<>::cBarra,::cBarra,"") //Adiciona somente se o último caracter for diferente de "\"
		If !ExistDir(::cPastaDest) //Se Pasta não existe
			MsgStop("Atenção! O Caminho para exportação informado é inválido e, portanto, a exportação está sendo abortada.","CAMINHO INVÁLIDO")
			Return Nil
		Endif
	Endif
	
Return (lRet)


//#############################################
//FUNÇÕES AUXILIARES
//#############################################

//Tratamento para carregar os parametros a partir da funcao ParamBox 
Static Function LoadParBox(cGrupoPerg)
Local cBuffer   := ""
Local nCont     := 1
Local lRet      := .T.
Local cArquivo	:= "\PROFILE\"+Alltrim(__CUSERID+"_"+cGrupoPerg)+".PRB"

	If File(cArquivo)
		If FT_FUse(cArquivo)<> -1
			FT_FGOTOP()
			While !FT_FEOF()
				cBuffer := FT_FREADLN()
				If SubStr(cBuffer,01,01) != "1"
					
					If SubStr(cBuffer,01,01) == "D"
						&("MV_PAR"+IIF(nCont > 9,cValToChar(nCont),"0"+cValToChar(nCont))):= CTOD(SubStr(cBuffer,02,10))
					ElseIf SubStr(cBuffer,01,01) == "N"
						&("MV_PAR"+IIF(nCont > 9,cValToChar(nCont),"0"+cValToChar(nCont))):= Val(SubStr(cBuffer,02,Len(cBuffer)))
					ElseIf SubStr(cBuffer,01,01) == "C"
						&("MV_PAR"+IIF(nCont > 9,cValToChar(nCont),"0"+cValToChar(nCont))):= SubStr(cBuffer,02,Len(cBuffer))
					ElseIF SubStr(cBuffer,01,01) == "L"
						&("MV_PAR"+IIF(nCont > 9,cValToChar(nCont),"0"+cValToChar(nCont))):= IIF( SubStr(cBuffer,02,01)=="F",.F.,.T.)
					Else
						&("MV_PAR"+IIF(nCont > 9,cValToChar(nCont),"0"+cValToChar(nCont))):= SubStr(cBuffer,02,Len(cBuffer))
						
					EndIF
					nCont++
					
				EndIf
				FT_FSKIP()
			EndDO
			
		Else
			lRet := .F.
		EndIF
	Else
		lRet := .F.
	EndIf
	FT_FUSE()
Return(lRet)

//Função para Gravar Dados em Arquivo
Static Function MemoWrite2(cArquivo,uConteudo)
Local nArq		:= 0
Local nCont		:= 0
Local cConteudo := ""

	Default uConteudo := ""

	If ValType(uConteudo) == "C"     
		//Usa a Função Padrão para Gravação do Arquivo
	    MemoWrite(cArquivo,uConteudo)
	ElseIf ValType(uConteudo) == "A"
		//Cria um Arquivo
		nArq := fCreate(cArquivo,nil,nil,.F.)
		             
		For nCont:=1 to Len(uConteudo)
			//Recupera o Conteúdo a ser Gravado
			cConteudo := uConteudo[nCont]
			
			//Grava o Conteúdo em Arquivo
			If !Empty(cConteudo)
				fWrite(nArq,cConteudo,Len(cConteudo))
			Endif
		Next nCont		
        
		//Fecha o Arquivo
		fClose(nArq)
	Endif

Return Nil
