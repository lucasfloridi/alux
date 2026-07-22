#Include "Protheus.ch"

/*/{Protheus.doc} COMXLEG
Ponto de entrada do COMXCOL (funcao COMCOLLEG), chamado via
ExecBlock("COMXLEG",.F.,.F.,{aCores}), permite incluir / alterar as linhas da
janela de Legenda. Formato de cada item do array: {"BR_COR", "Descricao"}.

Aqui incluimos a legenda do documento DESCONSIDERADO, associada ao mesmo
recurso usado no COMXACOR (BR_CANCEL - bolinha com X).

@type    function
@author  FixSystem - Leonardo Barboza Ribeiro Leite
@since   10/07/2026
@param   PARAMIXB, array, aCores atual {cor, descricao}
@return  array, aCores com a nova legenda incluida
/*/
User Function COMXLEG()

	Local aCores := {}
	Local aParam := PARAMIXB

	// Recupera o aCores recebido do fonte padrao
	If ValType(aParam) == "A" .And. Len(aParam) >= 1 .And. ValType(aParam[1]) == "A"
		aCores := aParam[1]
	EndIf

	// Inclui a descricao da legenda de desconsideracao
	If SDS->(FieldPos("DS_XCIENC")) > 0
		aAdd(aCores, {'BR_CANCEL', "Documento desconsiderado"})
	EndIf

Return aCores
