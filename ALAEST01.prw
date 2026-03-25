#include "Protheus.ch"
#include "TopConn.ch"

/*/{Protheus.doc} ALAEST01
Rotina chamada via valida��o de usu�rio no campo D3_DOC para verificar se o numero do ticket informado � unico
@type function
@author Tiago TOTVS IP
@since 05/07/2021
@return logical, .T. o numero informado � unico, .F. j� existe documento com o numero informado
@history 08/07/2021, Tiago TOTVS IP, Adicionada verifica��o para desconsiderar apontamentos extornados
/*/
User Function ALAEST01()
	Local lRet      := .T.
	Local cAlias	:= ""


	If FUNNAME()=="MATA250"
		cAlias := GetNextAlias()
		If !Empty(M->D3_DOC)
			BeginSQL Alias cAlias
        SELECT
            D3_DOC

        FROM
            %Table:SD3% SD3
        WHERE
            SD3.%NotDel%
            AND D3_DOC = %exp:M->D3_DOC%
            AND D3_ESTORNO <> 'S'
			EndSQL

			If (cAlias)->(!Eof())
				Help(NIL, NIL, "D3_DOC", NIL, "O numero do ticket informado j� existe.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um numero de ticket diferente"})
				lRet := .F.
			EndIf
		EndIf
		(cAlias)->(DbCloseArea())

	EndIf


Return lRet
