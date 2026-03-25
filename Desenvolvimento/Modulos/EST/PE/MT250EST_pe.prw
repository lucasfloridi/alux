#include "Protheus.ch"
#include "TopConn.ch"
/*/{Protheus.doc} MT250EST
Executado na função A250Estorn( ), responsavel pelo estorno de produção. Chamado apos confirmação de estorno de produções. 
Este ponto de entrada permite validar algum campo especifico do usuario antes de se realizar o Estorno.
@type function
@author Tiago TOTVS IP
@since 11/03/2021
@return logical, lRet, .T. caso possa prosseguir com o estorno; .F. caso não possa prosseguir com o estorno
/*/
User Function MT250EST()
    Local lRet      := .T.
    Local cQuery    := ""
    Local cAlias    := ""

    cQuery += "SELECT C6_NUM " + CRLF

	cQuery += "FROM "+RetSqlName("SC6")+" SC6 " + CRLF

    cQuery += "WHERE SC6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "      AND SC6.C6_ZZTICKE  <> ''" + CRLF
	cQuery += "      AND SC6.C6_ZZTICKE  = '" + SD3->D3_DOC + "'" + CRLF

    cQuery    := ChangeQuery(cQuery)

	memowrite("\sql\MT250EST_GetSC6.sql",cQuery)

	TCQuery cQuery New Alias (cAlias := GetNextAlias())

	DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

	If (cAlias)->(!EoF())
        lRet := .F.
        Aviso("AVISO","Não é possível estornar a movimentação. Existem pedidos de venda vinculados a essa movimentação.",{"Ok"},3)
    EndIf

Return lRet
