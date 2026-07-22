#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#Define _crlf Chr(13)+Chr(10)

User Function CheckAgent()
	Local aWAInfo := GetWebAgentInfo()
	Local cVersao := ""
	Local nPorta := 0

	IF ValType(aWAInfo) == "A" .AND. Len(aWAInfo) >= 2
		cVersao := aWAInfo[1]
		nPorta := aWAInfo[2]
	EndIf

	// Verifica se a string da versão está vazia para determinar se o WebAgent está ativo.
	IF Empty(cVersao)
		MsgStop("O WebAgent não está em execução ou não foi detectado.", "Status do WebAgent")
		// Opcionalmente, você pode forçar o logoff do usuário aqui, se necessário.
		// nRet := MSGERRO("O WebAgent não está em execução. O sistema será fechado.", "ERRO")
		// Bye()
		Return .F.
	ENDIF
REturn .T.
