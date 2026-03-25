#include "totvs.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} User Function MarkPesBal
	(long_description)
	@type  Function
	@author Diogo Mesquita
	@since 29/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function MarkPesBal()
	
	Local aCampos	:= {}
	Local lMarcar	:= .F.
	Local aSeek		:= {}
	Local cAlias	:= GetNextAlias()
	Local oTable	:= nil
	Local cDescItem	:= ""
	Local aRotBkp	:= {}
	
	Private oBrowse	:= Nil
	Private cTitulo	:= "Movimentos de Pesagem da Balança"
	
	If Type('aRotina') == 'A'
		aRotBkp := aClone(aRotina)

		aRotina := FWLOADMENUDEF("MarkPesBal")
	EndIf

	aAdd(aCampos,{"TRB_OK"  	,"C",002,000})
	aAdd(aCampos,{"TRB_FILIAL"  ,"C",004,000})
	aAdd(aCampos,{"TRB_SEQUEN"  ,"C",006,000})
	aAdd(aCampos,{"TRB_PESLIQ"  ,"N",011,004})
	aAdd(aCampos,{"TRB_DTPEIN"  ,"D",008,000})
	aAdd(aCampos,{"TRB_HRPEIN" 	,"C",008,000})
	aAdd(aCampos,{"TRB_DTPEFI"  ,"D",008,000})
	aAdd(aCampos,{"TRB_HRPEFI"  ,"C",008,000})
	aAdd(aCampos,{"TRB_CODITE"  ,"C",015,000})
	aAdd(aCampos,{"TRB_DESITE"  ,"C",030,000})
		
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf

	oTable := FWTemporaryTable():New("TRB",aCampos)	

	oTable:AddIndex("1", { "TRB_SEQUEN" })

	oTable:Create()
	dbSelectArea("TRB")
	TRB->(dbSetOrder(1))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSqlName("ZZ1") + " ZZ1 "
	cQuery += "WHERE ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' "
	cQuery += "AND ZZ1.ZZ1_UTILIZ = ' ' "
	cQuery += "AND ZZ1.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY ZZ1.ZZ1_FILIAL, ZZ1.ZZ1_SEQUEN "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	TCSetField(cAlias,"ZZ1_DTPEIN","D")
	TCSetField(cAlias,"ZZ1_DTPEFI","D")

	Do While (cAlias)->(!Eof())
		If SB1->(DbSeek(xFilial("SB1") + (cAlias)->ZZ1_CODITE))		
			cDescItem := SB1->B1_DESC	

			If RecLock("TRB",.T.)
				TRB->TRB_OK		:= "  "
				TRB->TRB_FILIAL := (cAlias)->ZZ1_FILIAL
				TRB->TRB_SEQUEN := (cAlias)->ZZ1_SEQUEN
				TRB->TRB_PESLIQ := (cAlias)->ZZ1_PESLIQ
				TRB->TRB_DTPEIN := (cAlias)->ZZ1_DTPEIN
				TRB->TRB_HRPEIN := (cAlias)->ZZ1_HRPEIN
				TRB->TRB_DTPEFI := (cAlias)->ZZ1_DTPEFI
				TRB->TRB_HRPEFI := (cAlias)->ZZ1_HRPEFI
				TRB->TRB_CODITE := (cAlias)->ZZ1_CODITE
				TRB->TRB_DESITE := cDescItem
				
				TRB->(MsUnLock())
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	TRB->(DbGoTop())
	If TRB->(!Eof())
		aAdd(aSeek,{"Sequencial"	,{{"","C",050,000,"Sequencial","@!"}} } ) 
		
		oBrowse:= FWMarkBrowse():New()
		oBrowse:SetDescription(cTitulo) //Titulo da Janela
		oBrowse:SetMenuDef("MarkPesBal")
		oBrowse:SetAlias("TRB") //Indica o alias da tabela que será utilizada no Browse
		oBrowse:SetFieldMark("TRB_OK") //Indica o campo que deverá ser atualizado com a marca no registro
		oBrowse:oBrowse:SetDBFFilter(.T.)	
		oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
		oBrowse:oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
		oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
		oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
		oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
		oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

		oBrowse:SetColumns(defColumn("TRB_FILIAL","Filial"				,"@!" 				,1,004,000))
		oBrowse:SetColumns(defColumn("TRB_SEQUEN","Sequencial"			,"@!" 				,1,006,000))
		oBrowse:SetColumns(defColumn("TRB_PESLIQ","Peso Líquido"		,"@E 999,999.9999"	,1,011,004))
		oBrowse:SetColumns(defColumn("TRB_DTPEIN","Dt. Peso Inicial"	,""					,1,008,000))
		oBrowse:SetColumns(defColumn("TRB_HRPEIN","Hr. Peso Inicial"	,"99:99:99"			,1,008,000))
		oBrowse:SetColumns(defColumn("TRB_DTPEFI","Dt. Peso Final"		,""					,1,008,000))
		oBrowse:SetColumns(defColumn("TRB_HRPEFI","Hr. Peso Final"		,"99:99:99"			,1,008,000))
		oBrowse:SetColumns(defColumn("TRB_CODITE","Cód. Item"			,"@!"				,1,015,000))
		oBrowse:SetColumns(defColumn("TRB_DESITE","Descrição Item"		,"@!"				,1,030,000))

		If isInCallStack('MATA250') // Apontamento Simples de Produção (MATA250)
			oBrowse:bMark := {|| AtMark(), oBrowse:Refresh(.F.) }
		Else
			oBrowse:bMark := {|| }
		EndIf

		If isInCallStack('MATA103') // Documento de Entrada (MATA103)
			oBrowse:bAllMark := {|| InvertM(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.) }
		Else
			oBrowse:bAllMark := {|| }	
		EndIf

		oBrowse:Activate()
        oBrowse:oBrowse:Setfocus()
	Else
		Return
	EndIf

	If(Type('oTable') <> 'U')
        oTable:Delete()
        oTable := Nil
    Endif

	If Type('aRotina') == 'A'
		aRotina := aClone(aRotBkp)
	EndIf

Return(.T.)

//Função para definição do MenuDef
static function MenuDef()
	local aRotina := {}
	
	ADD OPTION aRotina Title 'Carregar Itens' Action 'U_setItemBal()' OPERATION 7 ACCESS 0
return aRotina

//Função para marcar/desmarcar todos os registros do grid
Static Function InvertM(cMarca,lMarcar)

	Local aArea  := TRB->(getArea())

	lMarcar := !lMarcar
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	Do While !TRB->(Eof())
		RecLock("TRB",.F.)
		TRB->TRB_OK := IIf( lMarcar,cMarca,"  ")
		MsUnlock()
		TRB->(dbSkip())
	EndDo

	RestArea(aArea)
Return .T.


Static Function defColumn(cCampo,cTitulo,cPicture,nAlign,nSize,nDecimal)
	
	Local aColumn	:= {}
	Local bData 	:= {|| }
	
	bData := &("{||" + AllTrim(cCampo) + "}")
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

User function setItemBal() 
	
	Local cMarca		:= oBrowse:Mark()
	Local cReadBkp		:= ReadVar()
	Local nY			:= 0
	Local nItem			:= 1
	Local aAreaSB1		:= SB1->(GetArea())
	Local aFisRefSD1	:= {}
	
	dbSelectArea("TRB")
	TRB->(DbGoTop())

	If isInCallStack('MATA103') // Documento de Entrada (MATA103)
		aFisRefSD1 := MaFisSXRef("SD1")
		aCols := {}
		MaFisEnd()
		MaFisIni(cA100For,cLoja,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,.F.)
		
		// Atualiza UF de Origem apos a inicializacao das rotinas fiscais			
		MaFisAlt("NF_UFORIGEM",cUfOrig)
	EndIf

	While !TRB->(EoF())

		If TRB->TRB_OK == cMarca
			
			If SB1->(DbSeek(xFilial("SB1") + TRB->TRB_CODITE))
		
				// Popula campos da enchoice da tela de Apontamento Simples de Produção (MATA250)
				If isInCallStack('MATA250')
					M->D3_COD		:= SB1->B1_COD
					__ReadVar := "M->D3_COD"
					lRet := CheckSX3("D3_COD")
					If lRet
						If ExistTrigger("D3_COD")
							RunTrigger(1,Nil,Nil,,"D3_COD")
						EndIf
					EndIf
					
					M->D3_QUANT		:= TRB->TRB_PESLIQ
					M->D3_DOC		:= TRB->TRB_SEQUEN
				EndIf
				
				// Popula grid de itens da tela de Documento de Entrada (MATA103)
				If isInCallStack('MATA103')

					aAdd(aCols,Array(Len(aHeader)+1))
					nItem := Len(aCols)

					For nY := 1 To Len(aHeader)
						If Trim(aHeader[nY][2]) == "D1_ITEM"
							aCols[Len(aCols)][nY] := StrZero(nItem,Len(SD1->D1_ITEM))
						Else
							If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
								aCols[Len(aCols)][nY] := "SD1"
							ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
								aCols[Len(aCols)][nY] := 0
							Else
								aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
							EndIf
						EndIf
						aCols[Len(aCols)][Len(aHeader)+1] := .F.
					Next nY 

					aCols[Len(aCols),GdFieldPos("D1_COD")]     := SB1->B1_COD
					aCols[Len(aCols),GdFieldPos("D1_QUANT")]   := TRB->TRB_PESLIQ
					aCols[Len(aCols),GdFieldPos("D1_LOCAL")]   := SB1->B1_LOCPAD
					aCols[Len(aCols),GdFieldPos("D1_UM")] 	   := SB1->B1_UM
					aCols[Len(aCols),GdFieldPos("D1_ZZTICKE")] := TRB->TRB_SEQUEN
					
					//aCols[Len(aCols),GdFieldPos("D1_VUNIT")]   := 1.00
					//aCols[Len(aCols),GdFieldPos("D1_TES")]     := "001"
			
					N := Len(aCols)
					MaFisIniLoad(len(aCols))
					For nY := 1 To Len(aFisRefSD1)
						If GdFieldPos(aFisRefSD1[nY][1]) > 0
							MaFisLoad(aFisRefSD1[nY][2],aCols[Len(aCols),GdFieldPos(aFisRefSD1[nY][1])],Len(aCols))
						EndIf
					Next nY
					MaFisEndLoad(Len(aCols),2)
					
					M->D1_COD := aCols[Len(aCols)][GdFieldPos('D1_COD')]
					If ExistTrigger("D1_COD")
						RunTrigger(2,N,,"D1_COD")
					EndIf
					
					/*
					M->D1_VUNIT := aCols[Len(aCols)][GdFieldPos('D1_VUNIT')]
					If ExistTrigger("D1_VUNIT")
						RunTrigger(2,N,,"D1_VUNIT")
					EndIf
					
					MaFisLoad("IT_TES","",Len(aCols))
					MaFisAlt("IT_TES",aCols[Len(aCols)][GdFieldPos('D1_TES')],Len(aCols))
					MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
					If ExistTrigger("D1_TES")
						RunTrigger(2,Len(aCols),,"D1_TES")
					EndIf
					*/
					oGetDados:oBrowse:Refresh()	
					oGetDados:ForceRefresh()
				EndIf

				/* Popula grid de itens da tela de Pedido de Venda (MATA410)
				If Len(aCols) >= 1
					If !Empty(aCols[Len(aCols),GdFieldPos("C6_PRODUTO")])
						nItem := Val(aCols[Len(aCols),1])+1
						aAdd(aCols,Array(Len(aHeader)+1))
						For nY := 1 To Len(aHeader)
							If Trim(aHeader[nY][2]) == "C6_ITEM"
								aCols[Len(aCols)][nY] := StrZero(nItem,Len(SC6->C6_ITEM))
							Else
								If AllTrim(aHeader[nY,2]) == "C6_ALI_WT"
									aCols[Len(aCols)][nY] := "SC6"
								ElseIf AllTrim(aHeader[nY,2]) == "C6_REC_WT"
									aCols[Len(aCols)][nY] := 0
								Else
									aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
								EndIf					
							EndIf
							aCols[Len(aCols)][Len(aHeader)+1] := .F.
						Next nY 	
					EndIf
				EndIf
				
				N := Len(aCols)
				M->C6_PRODUTO := TRB->TRB_CODITE
				A410Produto(TRB->TRB_CODITE,.F.)
				aCols[Len(aCols),GdFieldPos("C6_PRODUTO")] := TRB->TRB_CODITE
				A410MultT("M->C6_PRODUTO",TRB->TRB_CODITE)
				If ExistTrigger("C6_PRODUTO")
					RunTrigger(2,N,Nil,,"C6_PRODUTO")
				EndIf

				A410SegUm(.T.)
				aCols[Len(aCols),GdFieldPos("C6_QTDVEN")]  := TRB->TRB_PESLIQ
				A410MultT("M->C6_QTDVEN",TRB->TRB_PESLIQ)
				If ExistTrigger("C6_QTDVEN ")
					RunTrigger(2,N,Nil,,"C6_QTDVEN ")
				EndIf

				aCols[Len(aCols),GdFieldPos('C6_TES')] := "501"
				A410MultT("M->C6_TES","501")
				If ExistTrigger("C6_TES")
   					RunTrigger(2,Len(aCols),,"C6_TES")
				EndIf
				
				aCols[Len(aCols),GdFieldPos("C6_PRCVEN")] := 1.00
				A410MultT("M->C6_PRCVEN",1.00)
				If ExistTrigger("C6_PRCVEN")
   					RunTrigger(2,Len(aCols),,"C6_PRCVEN")
				EndIf

				aCols[Len(aCols),GdFieldPos("C6_UM")] := SB1->B1_UM
				If Empty(aCols[Len(aCols),GdFieldPos("C6_LOCAL")])
					aCols[Len(aCols),GdFieldPos("C6_LOCAL")] := SB1->B1_LOCAL
				EndIf
				
				oGetDad:ForceRefresh()
				*/

				RecLock("TRB",.F.)
					TRB->(dbDelete())
				TRB->(MsUnlock())
			EndIf	

		EndIf

		TRB->(DbSkip())

	EndDo

	TRB->(DbGoTop())
	__ReadVar := cReadBkp

	RestArea(aAreaSB1)
	oBrowse:getOwner():End()
	
	//ApMsgInfo("Processamento concluído com sucesso!","SUCESSO")

Return Nil

//Funcao executada ao Marcar/Desmarcar um registro
Static Function AtMark()
	Local cSeq := ""
	Local cMarca := oBrowse:cMark
	//Local aArea  := TRB->(getArea())
	Local nRec    	:= TRB->(Recno())
	
	cSeq := TRB->TRB_SEQUEN

	If TRB->TRB_OK == cMarca
		TRB->(DbGoTop())
		Do While !TRB->(Eof())
			If TRB->TRB_SEQUEN == cSeq
				RecLock("TRB",.F.)
				TRB->TRB_OK := cMarca
				MsUnLock()
			Else
				RecLock("TRB",.F.)
				TRB->TRB_OK := ""
				MsUnLock()
			EndIf
			TRB->(dbSkip())
		EndDo
	Else
		TRB->(DbGoTop())
		Do While !TRB->(Eof())
			RecLock("TRB",.F.)
			TRB->TRB_OK := ""
			MsUnLock()
			TRB->(dbSkip())
		EndDo
	EndIf
	
	//RestArea(aArea)
	TRB->(DbGoTo(nRec))
	//oBrowse:GoPgDown()
	//oBrowse:GoPgUp()
	
Return
