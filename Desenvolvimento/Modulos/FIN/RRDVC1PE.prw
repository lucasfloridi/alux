#Include "Totvs.ch"


User Function RRDVC1PE()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := Nil
    Local IdPonto := ''
    Local IdModel := ''
    Local nOper := 0
    Local cSol  := ""
    
    If aParam <> Nil

        oObj := aParam[1]
        IdPonto := aParam[2]
        IdModel := aParam[3]

        If IdPonto == "MODELVLDACTIVE"
            nOper := oObj:nOperation

            If (nOper == 5 .OR. nOper == 4 ) .AND. SZM->ZM_STATUS != "1"
                // Solucao conforme o status: 'Enviado para Aprovacao' (2) pode ser
                // reprovado e voltar para 'Pendente'; 'Aprovado'/'Pago' (3/4) NAO
                // retornam o status.
                If SZM->ZM_STATUS == "2"
                    cSol := "Reprove a despesa para retornar ao status 'Pendente' e entao alterar ou excluir."
                Else
                    cSol := "Despesa aprovada ou paga nao pode ser alterada/excluida nem retornar ao status 'Pendente'."
                EndIf
                // Registra o erro NO MODELO (mensagem unica do framework). O
                // FWAlertError + .F. gerava uma 2a mensagem em branco.
                oObj:SetErrorMessage("SZMMASTER", "ZM_STATUS", "SZMMASTER", "ZM_STATUS", "RRDVC1PE",;
                    "Apenas despesas com status 'Pendente' podem ser alteradas ou excluidas!", cSol)
                xRet := .F.
            EndIf
        EndIf
    EndIf
Return xRet
