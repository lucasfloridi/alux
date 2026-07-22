#Include "Protheus.ch"

/*/{Protheus.doc} COMXACOR
Ponto de entrada do COMXCOL (Monitor TOTVS Colaboracao / Importador XML).
Chamado na funcao COMXCOL via ExecBlock("COMXACOR",.F.,.F.,{aCores}), permite
incluir / alterar as regras de COR (semaforo) das linhas do browse.
Formato de cada item do array: {condicao_ADVPL, "BR_COR"}.

Aqui incluimos a regra do documento DESCONSIDERADO (DS_XCIENC == "1"),
exibindo a bolinha com X (recurso BR_CANCEL). A regra e inserida no INICIO do
array para ter prioridade (a primeira condicao que casa e a que vale).

@type    function
@author  FixSystem - Leonardo Barboza Ribeiro Leite
@since   10/07/2026
@param   PARAMIXB, array, aCores atual {condicao, cor}
@return  array, aCores com a nova regra incluida
/*/
User Function COMXACOR()

	Local aCores := {}
	Local aNew   := {}
	Local aParam := PARAMIXB
	Local nX     := 0

	// Recupera o aCores recebido do fonte padrao
	If ValType(aParam) == "A" .And. Len(aParam) >= 1 .And. ValType(aParam[1]) == "A"
		aCores := aParam[1]
	EndIf

	// So aplica a cor se o campo de desconsideracao existir no dicionario da SDS
	If SDS->(FieldPos("DS_XCIENC")) > 0
		aAdd(aNew, {'DS_XCIENC == "1"', 'BR_CANCEL'})
	EndIf

	// Mantem as regras padrao apos a nossa (prioridade da desconsideracao)
	For nX := 1 To Len(aCores)
		aAdd(aNew, aCores[nX])
	Next nX

Return aNew
