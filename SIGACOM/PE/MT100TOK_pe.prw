#include "Protheus.ch"


/*/{Protheus.doc} MT100TOK
Ponto de entrada na inclusão de NF de entrada para validação Tudo OK.
Se Verdadeiro (.T.), atualizara o movimento, de acordo com os dados digitados pelo usuario.
Se for falso (.F.) nao prosseguira com a implantacao.
@type function
@author Tiago Badoco - TOTVS IP
@since 23/02/2021
@return logical, nRet, Tudo OK
/*/
User Function MT100TOK()
    Local nRet      := .T.
    Local nX        := 0
    Local nPosRat   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_RATEIO"})
    lOCAL nPosCon   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CONTA"})

    If !FwIsInCallStack("MATA920") 
        For nX := 1 to Len(aCols)
            If !nRet
                Exit
            EndIf

            If (aCols[nX][nPosRat] == "2")
                If (Empty(aCols[nX][nPosCon]))
                    nRet    := .F.

                    Help(NIL, NIL, "C Contábil em branco", NIL, "É necessário informar uma C Contábil para o item " + cValToChar(nX) + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe uma C Contábil para o item " + cValToChar(nX)})
                EndIf
            EndIf
        Next nX
    EndIf


Return nRet
