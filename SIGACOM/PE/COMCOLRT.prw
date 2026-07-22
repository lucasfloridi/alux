#Include "Protheus.ch"

/*/{Protheus.doc} COMCOLRT
Ponto de entrada do COMXCOL (Monitor TOTVS Colaboracao / Importador XML).
Chamado em COMXCOL.PRW (MenuDef) via ExecBlock("COMCOLRT",.F.,.F.,{aRotina}),
permite alterar o aRotina (menu "Outras Acoes").

Aqui incluimos a opcao "Desconsiderar Doc.", que registra a CIENCIA DE
DESCONSIDERACAO de um documento: o usuario da ciencia de que aquele documento
NAO sera escriturado e, com isso, ele deixa de sair no relatorio de
escrituracao pendente RCOMR005 (flag DS_XCIENC == "1").

@type    function
@author  FixSystem - Leonardo Barboza Ribeiro Leite
@since   10/07/2026
@param   PARAMIXB, array, aRotina atual do COMXCOL
@return  array, aRotina com a nova opcao incluida
/*/
User Function COMCOLRT()

	Local aRotina := {}
	Local aParam  := PARAMIXB

	// Recupera o aRotina recebido do fonte padrao
	If ValType(aParam) == "A" .And. Len(aParam) >= 1 .And. ValType(aParam[1]) == "A"
		aRotina := aParam[1]
	EndIf

	// So inclui a opcao se o campo de desconsideracao existir no dicionario da SDS
	If SDS->(FieldPos("DS_XCIENC")) > 0
		//        Titulo               Funcao        0  Oper.  0  Acessa
		aAdd(aRotina, {"Desconsiderar Doc.", "U_COMCOLDES", 0, 4, 0, .F.})
	EndIf

Return aRotina

/*/{Protheus.doc} COMCOLDES
Registra ou remove a CIENCIA DE DESCONSIDERACAO do documento posicionado no
monitor (tabela SDS). O usuario da ciencia de que o documento nao sera
escriturado; com DS_XCIENC == "1" ele e desconsiderado no relatorio RCOMR005.

Operacao reforcada com confirmacao do usuario e auditoria (usuario/data/hora),
gravados apenas se os respectivos campos existirem no dicionario.

@type    function
@author  FixSystem - Leonardo Barboza Ribeiro Leite
@since   10/07/2026
@param   cAlias, character, alias do browse (SDS) - opcional
@param   nReg,   numeric,   recno do registro posicionado - opcional
@param   nOpc,   numeric,   operacao do aRotina - opcional
@return  Variant, Sempre Nil (nao retorna valor)
/*/
User Function COMCOLDES(cAlias, nReg, nOpc)

	Local lDescart := .F. as Logical  // .T. = documento ja esta desconsiderado
	Local cChv     := ""  as Character // chave do documento (doc/serie)
	Local cPerg    := ""  as Character // pergunta de confirmacao

	Default cAlias := "SDS"
	Default nReg   := 0
	Default nOpc   := 0

	// Garante o posicionamento no registro selecionado no browse
	If nReg > 0
		SDS->(DbGoto(nReg))
	EndIf

	lDescart := SDS->DS_XCIENC == "1"
	cChv     := AllTrim(SDS->DS_DOC) + " / " + AllTrim(SDS->DS_SERIE)

	If lDescart
		cPerg := "O documento " + cChv + " esta DESCONSIDERADO." + CRLF
		cPerg += "Deseja REATIVAR? (o documento voltara a aparecer no relatorio RCOMR005)"
	Else
		cPerg := "Dar ciencia de DESCONSIDERACAO no documento " + cChv + " ?" + CRLF
		cPerg += "Ele deixara de aparecer no relatorio de escrituracao pendente (RCOMR005)."
	EndIf

	If FWAlertYesNo(cPerg, "Ciencia de Desconsideracao - Importador XML")

		if RecLock("SDS", .F.)

			SDS->DS_XCIENC := Iif(lDescart, "2", "1")
			SDS->DS_XCUSER := Iif(lDescart, "", cUserName)
			SDS->DS_XCDATA := Iif(lDescart, CToD("  /  /    "), dDataBase)
			SDS->DS_XCHORA := Iif(lDescart, "", Time())

			MsUnlock()
		else
			FWAlertError("Registro em uso por outro usuario.", "Importador XML")
			return
		endif

		// Atualiza o browse do monitor (funcao do proprio COMXCOL)
		If FindFunction("COLATUBRW")
			COLATUBRW()
		EndIf

		FWAlertSuccess(Iif(lDescart, "Documento REATIVADO com sucesso.", "Documento DESCONSIDERADO com sucesso."), "Importador XML")

	EndIf

Return (Nil)
