#include "totvs.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} User Function UpdPesBal
	(long_description)
	@type  Function
	@author Diogo Mesquita
	@since 09/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function UpdPesBal(cUtilizado)

    Local aAreaSD1		:= {}
    Local aAreaZZ1		:= {}
	Local aAreaSD3		:= {}
	Local nPosTicket	:= 0
	Local nI			:= 0
	
	Default cUtilizado	:= "S"

	If isInCallStack('MATA250') // Apontamento Simples de Produção (MATA250)
		aAreaSD3  := SD3->(GetArea())

		If !Empty(SD3->D3_DOC)
			DbSelectArea("ZZ1")
			ZZ1->(DbSetOrder(1)) // ZZ1_FILIAL + ZZ1_SEQUEN
			If ZZ1->(DbSeek(xFilial("ZZ1") + Padr(SD3->D3_DOC,TamSx3("ZZ1_SEQUEN")[1])))
				RecLock("ZZ1",.F.)
				ZZ1->ZZ1_UTILIZ := cUtilizado
				ZZ1->(MsUnLock())
			EndIf
		EndIf

		RestArea(aAreaSD3)
	EndIf

	If isInCallStack('MATA103') // Documento de Entrada (MATA103)
		/*
		aAreaSD1  := SD1->(GetArea())
    	aAreaZZ1  := ZZ1->(GetArea())

		DbSelectArea("SD1")
		SD1->(DbSetOrder(1)) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
		SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		
		Do While SD1->(!Eof()) .AND. SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA .AND. SD1->D1_FILIAL == xFilial("SD1")
			If !Empty(SD1->D1_ZZTICKE)
				DbSelectArea("ZZ1")
				ZZ1->(DbSetOrder(1)) // ZZ1_FILIAL + ZZ1_SEQUEN
				If ZZ1->(DbSeek(xFilial("ZZ1") + SD1->D1_ZZTICKE))
					RecLock("ZZ1",.F.)
					ZZ1->ZZ1_UTILIZ := cUtilizado
					ZZ1->(MsUnLock())
				EndIf
			EndIf
			
			SD1->(DbSkip())
		EndDo

		RestArea(aAreaZZ1)
		RestArea(aAreaSD1)
		*/

		nPosTicket := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ZZTICKE"})
	
		DbSelectArea("ZZ1")
		ZZ1->(DbSetOrder(1)) // ZZ1_FILIAL + ZZ1_SEQUEN
					
		For nI := 1 to Len(aCols)
			If !aCols[nI][Len(aHeader)+1]
				cTicket := aCols[nI, nPosTicket]
				If !Empty(cTicket)
					If ZZ1->(DbSeek(xFilial("ZZ1") + cTicket))
						RecLock("ZZ1",.F.)
						ZZ1->ZZ1_UTILIZ := cUtilizado
						ZZ1->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Next

	EndIf

Return Nil
