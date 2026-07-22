#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GFGAT001 
Usado para preencher o nome do cliente ou fornecedor no pedido de venda,
Documento de Entrada e Documento de Saida. E descriçao do produto no
docuemnto de saida e liberaçao de pedidos.

@author Tiago Quintana
@since 09/01/2017
@version P12
/*/
//-------------------------------------------------------------------
User Function GFGAT001(nTp) //U_GFGAT001(1)

	Local cRet	:= ""
	Local cAux	:= ""
	Local aArea := GetArea()
	
		// DESCRICAO DO CLIENTE/FORNECEDOR
		// Gatilho Pedido de Venda = 1 -  Nome 40
	If nTp == 1
		If M->C5_TIPO == "B" .Or. M->C5_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + M->C5_CLIENTE + M->C5_LOJACLI,"A2_NOME")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_NOME")
		EndIf
		// Gatilho Pedido de Venda = 2 - Nome Fantasia 20
	ElseIf nTp == 2
		If M->C5_TIPO == "B" .Or. M->C5_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + M->C5_CLIENTE + M->C5_LOJACLI,"A2_NREDUZ")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_NREDUZ")
		EndIf	
		// Browse Pedido de Venda = 3 - Nome 40                               
	ElseIf nTp == 3
		If SC5->C5_TIPO == "B" .Or. SC5->C5_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A2_NOME")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_NOME")
		EndIf
		// Browse Pedido de Venda = 4 - Nome Fantasia 20                            
	ElseIf nTp == 4
		If SC5->C5_TIPO == "B" .Or. SC5->C5_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A2_NREDUZ")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_NREDUZ")
		EndIf
		// Browse Documento de Entrada = 5 - Nome 40                                
	ElseIf nTp == 5
		If SF1->F1_TIPO == "B" .Or. SF1->F1_TIPO == "D"
			cRet := Posicione("SA1",1,xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA,"A1_NOME")
		Else
			cRet := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_NOME")
		EndIf
		// Browse Documento de Entrada = 6 - Nome Fantasia 20                               
	ElseIf nTp == 6
		If SF1->F1_TIPO == "B" .Or. SF1->F1_TIPO == "D"
			cRet := Posicione("SA1",1,xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA,"A1_NREDUZ")
		Else
			cRet := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_REDUZ")
		EndIf	
		// Browse Documento de Saida = 7 - Nome 40                                
	ElseIf nTp == 7
		If SF2->F2_TIPO == "B" .Or. SF2->F2_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A2_NOME")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_NOME")
		EndIf
		// Browse Documento de Saida = 8 - Nome Fantasia 20                                 
	ElseIf nTp == 8
		If SF2->F2_TIPO == "B" .Or. SF2->F2_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A2_NREDUZ")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_NREDUZ")
		EndIf
		//  Documento de Saida itens = 9 - Nome 40                                
	ElseIf nTp == 9
		If SD2->D2_TIPO == "B" .Or. SD2->D2_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA,"A2_NOME")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA,"A1_NOME")
		EndIf
		//  Documento de Saida itens = 10 - Nome Fantasia 20                                 
	ElseIf nTp == 10
		If SD2->D2_TIPO == "B" .Or. SD2->D2_TIPO == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA,"A2_NREDUZ")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA,"A1_NREDUZ")
		EndIf
		//  Liberacao Pedido itens = 11 - Nome 40                                
	ElseIf nTp == 11
		cAux := Posicione("SC5",1,xFilial("SC5") + SC9->C9_PEDIDO,"C5_TIPO")
		If cAux== "B" .Or. cAux == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A2_NOME")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A1_NOME")
		EndIf
		//  Liberacao Pedido itens itens = 12 - Nome Fantasia 20                                 
	ElseIf nTp == 12
		cAux := Posicione("SC5",1,xFilial("SC5") + SC9->C9_PEDIDO,"C5_TIPO")
		If cAux== "B" .Or. cAux == "D"
			cRet := Posicione("SA2",1,xFilial("SA2") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A2_NREDUZ")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A1_NREDUZ")
		EndIf	
		//  DESCRICAO DO PRODUTO
		//  Documento de Saida itens = 20 - Descriçao Produto 30
	ElseIf nTp == 20
		cRet := Posicione("SB1",1,xFilial("SB1") + SD2->D2_COD,"B1_DESC")
		//  Liberação de Pedido itens = 21 - Descriçao Produto 30
	ElseIf nTp == 21
		cRet := Posicione("SB1",1,xFilial("SB1") + SC9->C9_PRODUTO,"B1_DESC")
	EndIf

	RestArea(aArea)

Return cRet

